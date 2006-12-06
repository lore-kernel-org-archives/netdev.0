From: "Dmitry Torokhov" <dmitry.torokhov@gmail.com>
Subject: Re: [RFC] rfkill - Add support for input key to control wireless radio
Date: Wed, 6 Dec 2006 10:24:08 -0500
Message-ID: <d120d5000612060724m7ebe0b1w5c0f24ba52ca75e7@mail.gmail.com>
References: <200612031936.34343.IvDoorn@gmail.com>
	 <d120d5000612041415r2f471e78s4feb86d22b7706d5@mail.gmail.com>
	 <200612050027.15253.IvDoorn@gmail.com>
	 <d120d5000612060637s69ff235fo85a2db923a728a00@mail.gmail.com>
	 <1165418339.2750.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Ivo van Doorn" <ivdoorn@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, "John Linville" <linville@tuxdriver.com>,
	"Jiri Benc" <jbenc@suse.cz>,
	"Lennart Poettering" <lennart@poettering.net>,
	"Johannes Berg" <johannes@sipsolutions.net>,
	"Larry Finger" <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S935072AbWLFPYN@vger.kernel.org>
To: "Dan Williams" <dcbw@redhat.com>
In-Reply-To: <1165418339.2750.5.camel@localhost.localdomain>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/6/06, Dan Williams <dcbw@redhat.com> wrote:
> On Wed, 2006-12-06 at 09:37 -0500, Dmitry Torokhov wrote:
> >
> > Fans of the 3rd method, speak up ;)
>
> I think I brought up the 3rd method initially in this thread.  I'm not
> necessarily advocating it, but I wanted to be sure people realized that
> this was a case, so that a clear decision would be made to support it or
> not to support it.
>
> (2) makes the most sense to me.  I don't think we need to care about
> edge-cases like "But I only wanted to rfkill _one_ of my bluetooth
> dongles!!!", that's just insane.
>
> But using (2) also begs the question, can we _always_ identify what
> interface the rfkill belongs to?  In Bastien's laptop, the rfkill switch
> _automatically_ disconnects the internal USB Bluetooth device from the
> USB bus, and uses the normal ipw2200 rfkill mechanism, whatever that is.
> In this case, you simply do not get an event that the bluetooth device
> is disabled from a button somewhere; it's just gone, and you'd have to
> do some magic to disable other bluetooth devices as well.
>

Is this the same physical button? If so then for this particular box
we'd just have to send 2 events - KEY_WIFI and KEY_BLUETOOTH at the
same time.

-- 
Dmitry
