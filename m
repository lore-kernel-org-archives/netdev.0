From: Sedat Dilek <sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Understanding what's going on when using a Huawei E173 USB 3G
 web-stick (UMTS/HSPA)
Date: Sun, 16 Nov 2014 02:40:15 +0100
Message-ID: <CA+icZUXFYYtvpKV-pOfj-pqhYD+TWBDB3SKKz_aBirrJbxvQkA@mail.gmail.com>
References: <CA+icZUXgLhuVSs0aqxi_e=GLZh-zX3JPMhDF+03ctr7O-Ae2og@mail.gmail.com>
	<1415120132.31049.11.camel@dcbw.local>
	<CA+icZUW2iRkoAK10ayJ9PFuFGWBQzKdFe+8mfd=8oKkAp1txtg@mail.gmail.com>
	<CA+icZUX6caBKnjMv6V_26y_-VNfDqkeXFXKJhDdQpZy7W4oofw@mail.gmail.com>
	<1415981880.22965.28.camel@dcbw.local>
	<CA+icZUUWK8R0zFLBHfvfE6zmZ7=+yP_FJgkkeELVbwdhPUYfRA@mail.gmail.com>
	<20141115200711.GA24643@kroah.com>
Reply-To: sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Aleksander Morgado <aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org>
To: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20141115200711.GA24643-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 15, 2014 at 9:07 PM, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org> wrote:
> On Sat, Nov 15, 2014 at 10:23:55AM +0100, Sedat Dilek wrote:
>> On Fri, Nov 14, 2014 at 5:18 PM, Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrot=
e:
>> > On Fri, 2014-11-14 at 11:56 +0100, Sedat Dilek wrote:
>> >> On Wed, Nov 12, 2014 at 2:21 PM, Sedat Dilek <sedat.dilek@gmail.c=
om> wrote:
>> >> > On Tue, Nov 4, 2014 at 5:55 PM, Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> =
wrote:
>> >> >> On Tue, 2014-11-04 at 16:11 +0100, Sedat Dilek wrote:
>> >> >>> Hi,
>> >> >>>
>> >> >>> I wanted to understand what is going on the kernel-side when
>> >> >>> connecting to the Internet via a Huawei E173 USB web-stick (3=
rd
>> >> >>> Generation: UMTS / HSPA).
>> >> >>>
>> >> >>> Especially the correlation between the diverse USB/NET kernel=
-drivers
>> >> >>> and how the networking is setup.
>> >> >>
>> >> >
>> >> > [ Sitting in front of a foreign Windows machine ]
>> >> >
>> >> > [ CC Aleksander ]
>> >> >
>> >> > Hi Dan,
>> >> >
>> >> > sorry for the late (and short) response.
>> >> >
>> >> > AFAICS you have given a "skeleton" for a "usb-wwan-networking"
>> >> > documentation :-).
>> >> >
>> >> > Personally, I would like to take into account some kernel-confi=
g
>> >> > options and some more things.
>> >> >
>> >>
>> >> I started with documenting...
>> >>
>> >> I have still some difficulties in understanding USB WWAN Networki=
ng.
>> >> So, this is what I revealed...
>> >>
>> >> ##### USB: HUAWEI E173 3G/UMTS/HSPA INTERNET STICK
>> >>
>> >> ### USB-NETWORKING AND WWAN SETUP
>> >> CONFIG_USB_USBNET=3Dm        <--- usb networking
>> >> CONFIG_USB_NET_CDCETHER=3Dm  <--- usb-wwan (net) configuration
>> >> CONFIG_USB_SERIAL_WWAN=3Dm   <--- usb-wwan (serial) configuration
>> >> CONFIG_USB_SERIAL_OPTION=3Dm <--- usb-serial driver called "optio=
n"
>> >
>> > Most WWAN devices actually require option, because most WWAN devic=
es
>> > have "serial" ports (even if they aren't used for PPP), and 'optio=
n' is
>> > the driver that handles this.  The 'option' name is historic, but =
the
>> > driver should really be called something like 'wwan-serial-generic=
' or
>> > something like that.
>> >=C3=B6"
>>
>> Is there sth. against renaming the "option" driver to "wwan-serial-g=
eneric"?
>
> Yes, people's scripts might break that are hard-coded to use the
> "option" driver.
>

As far as I read on LKML... breaking userspace is a reason not to do
such changes.
That's really a reason not to break "handmade" scripts on some machines=
?
As this is new to me... is that documented?
Surely, it's fretful to change scripts, but life is change.
=46or me there is a more reasonable thing... Did you grep for "option"
pattern in the kernel sources?
Try.... :-).

> thanks,
>
> greg "here, have a vowel, they are cheap" k-h

Hmm, being a non-English native, I am not sure to get this...
What about languages from mostly Eastern countries having so much
consonants in a single word like Russian, Polish, etc.
Not every language is rich like German which has WOWels like "=C3=A4" (=
ae)
"=C3=B6" (oe) "=C3=BC" (ue).

- Sedat -
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
