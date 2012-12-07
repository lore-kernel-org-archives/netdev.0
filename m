From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next v3 1/3] virtio-net: separate fields of
	sending/receiving queue from virtnet_info
Date: Fri, 7 Dec 2012 15:11:11 -0800
Message-ID: <20121207151111.7d2f9150@samsung-9>
References: <1354899897-10423-1-git-send-email-jasowang@redhat.com>
	<1354899897-10423-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	bhutchings@solarflare.com, jwhan@filewood.snu.ac.kr,
	davem@davemloft.net, shiyer@redhat.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1354899897-10423-2-git-send-email-jasowang@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Minor style issue reported by checkpatch which can be fixed after merge.
Although sizeof is actually an operator in C, it is considered correct
style to treat it as a function.


WARNING: sizeof hdr->hdr should be sizeof(hdr->hdr)
#293: FILE: drivers/net/virtio_net.c:395:
+	sg_set_buf(rq->sg, &hdr->hdr, sizeof hdr->hdr);

WARNING: sizeof hdr->mhdr should be sizeof(hdr->mhdr)
#552: FILE: drivers/net/virtio_net.c:641:
+		sg_set_buf(sq->sg, &hdr->mhdr, sizeof hdr->mhdr);

WARNING: sizeof hdr->hdr should be sizeof(hdr->hdr)
#555: FILE: drivers/net/virtio_net.c:643:
+		sg_set_buf(sq->sg, &hdr->hdr, sizeof hdr->hdr);
