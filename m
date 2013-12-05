From: Michael Dalton <mwdalton@google.com>
Subject: Re: [PATCH] virtio-net: free bufs correctly on invalid packet length
Date: Thu, 5 Dec 2013 13:12:51 -0800
Message-ID: <CANJ5vP+Wn-MkBgVezs1t=o3=cMMBQp4iJP9_QAUxVyWv7hKi6Q@mail.gmail.com>
References: <1386274612-18379-1-git-send-email-mwdalton@google.com>
	<52A0F979.1090309@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrey Vagin <avagin@openvz.org>, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org,
	lf-virt <virtualization@lists.linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <52A0F979.1090309@cogentembedded.com>
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

Thanks Sergei,

Yes this is a similar bugfix, the patch I saw from Andrey
fixed this issue in free_unused_bufs. The problem also occurs when
dropping a packet that is too short.  Apologies for forgetting to
sign off on the patch, I will re-send.

Best,

Mike
