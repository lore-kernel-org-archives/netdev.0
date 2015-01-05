From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v1 0/7] net: extend ethtool link mode bitmaps to
 48 bits
Date: Mon, 5 Jan 2015 01:34:26 +0100
Message-ID: <CAHo-Ooxi8V_58b456vePY9_7ChuBe0jxEVHvGkGvRBpAR744yA@mail.gmail.com>
References: <1420405017-23278-1-git-send-email-ddecotig@gmail.com>
	<1420408540.5686.140.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Decotigny <ddecotig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Amir Vadai <amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Linux NetDev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Decotigny <decot-Ypc/8FJVVoBWk0Htik3J/w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Jason Wang <jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	Masatake YAMATO <yamato-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Xi Wang <xii-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	WANG Cong <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Flavio Leitner <fbl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Tom Gundersen <teg-B22kvLQNl6c@public.gmane.org>,
	Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>,
	Vlad Yasevich <vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Venkata Duvvuru <VenkatKumar.Duvvuru-laKkSmNT4hbQT0dZR+AlfA@public.gmane.org>,
	Govindaraj
To: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1420408540.5686.140.camel-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

>> I can send updates to other drivers, even though it's rather pointless
>> to update 1G drivers at this point for example. Please let me know,
>> but I'd prefer to do this in follow-up patches outside this first
>> patch series.
> [...]
>
> They should be changed to ensure they reject setting any of the high
> advertising flags, but it's not urgent.

if old drivers advertised a get/set_bits function while new drivers
advertised a get/set_new_bits function,
you could not updated any old drivers, and simply take care of
rejecting invalid bits in core, by calling set_new_bits if provided,
if not, rejecting bad bits and calling set_bits if no bad bits were
set.
