From: Roland Stigge <stigge@antcom.de>
Subject: Re: 3.7-rc3 oops on reboot
Date: Mon, 29 Oct 2012 15:41:55 +0100
Message-ID: <508E95B3.7070807@antcom.de>
References: <CAAAP30E-g3YdXOMvfueDQZREZ+_Adi2uhxgLeqKixkupU+QNhA@mail.gmail.com> <508E7B47.60207@antcom.de> <CAAAP30HWhz_h4AVwjkw9APw6pv0ydO=GZ89uaBhKbmjw60ym4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexandre Pereira da Silva <aletes.xgr@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAAP30HWhz_h4AVwjkw9APw6pv0ydO=GZ89uaBhKbmjw60ym4Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/29/2012 02:51 PM, Alexandre Pereira da Silva wrote:
>> I just tried both on a PHY3250 reference machine, and on a custom board
>> and couldn't reproduce sth. like this. Booted the kernel and connected
>> the ethernet cable later on, as well as with cable connected on boot.
> 
> This is happening on my custom board. I didn't try this on the
> reference board yet.
> 
>> Any related patches applied? Can you reproduce this on a reference
>> machine? Can you provide a .config for this? Any more detail about how
>> this could be reproduced?
> 
> No patches applied. I'm trying to bisect this. This happens on a clean
> -rc1 as well. Doesn't happen on v3.6.
> 
> Attached my .config
> 
> To reproduce this, I am just running "reboot". I have the ethernet
> cable always connected here.

Just tried this with your .config on the PHY3250 (w/o your initrd
thought) but couldn't reproduce the issue.

Maybe it's related to your Micrel ethernet PHY (activated in your
config) which I don't have hardware for?

Otherwise, we would need to have a look at your devicetree.

Roland
