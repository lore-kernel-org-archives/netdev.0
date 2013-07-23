From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] tuntap: hardware vlan tx support
Date: Tue, 23 Jul 2013 08:53:10 -0700
Message-ID: <20130723085310.4a036a47@nehalam.linuxnetplumber.net>
References: <1374563748-38821-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Basil Gor <basil.gor@gmail.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1374563748-38821-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 23 Jul 2013 15:15:48 +0800
Jason Wang <jasowang@redhat.com> wrote:

> +		struct {
> +			__be16 h_vlan_proto;
> +			__be16 h_vlan_TCI;
> +		} veth;

Don't you want to use struct vlan_hdr here? 
Your definition puts the two fields out of order?
