From: "Bart Van Assche" <bart.vanassche@gmail.com>
Subject: Re: [PATCH][RFC 23/23]: Support for zero-copy TCP transmit of user space data
Date: Tue, 16 Dec 2008 17:00:07 +0100
Message-ID: <e2e108260812160800h66e525f2p8c6c78b1b73630d1@mail.gmail.com>
References: <494009D7.4020602@vlnb.net> <494012C4.7090304@vlnb.net>
	 <20081210214500.GA24212@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Vladislav Bolkhovitin" <vst@vlnb.net>, linux-scsi@vger.kernel.org,
	"James Bottomley" <James.Bottomley@hansenpartnership.com>,
	linux-kernel@vger.kernel.org, scst-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: "Evgeniy Polyakov" <zbr@ioremap.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20081210214500.GA24212@ioremap.net>
Content-Disposition: inline
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 10, 2008 at 10:45 PM, Evgeniy Polyakov <zbr@ioremap.net> wrote:
> Another approach is to increase skb's shared data (at the end of the
> skb->data), and this approach was not frowned upon too much either, but
> it requires to mess with skb->destructor, which may not be appropriate
> in some cases. If iscsi does not use sockets (it does iirc), things are
> much simpler.

Hello Evgeniy,

Any idea whether it would be acceptable to extend "struct sock" with
one or two pointers to callback functions ? These callback functions
could be called from skb_release_data() etc. through the "struct sock*
sk" member of "struct sk_buff".

Bart.
