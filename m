From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: ipw2100: firmware problem
Date: Sat, 11 Jun 2005 15:44:25 +0300
Message-ID: <200506111544.25462.vda__36495.8115890206$1118494070$gmane$org@ilport.com.ua>
References: <000f01c56dbf$9b15de90$600cc60a@amer.sykes.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <abonilla@linuxwireless.org>, "'Pavel Machek'" <pavel@ucw.cz>,
        "'Jeff Garzik'" <jgarzik@pobox.com>,
        "'Netdev list'" <netdev@oss.sgi.com>,
        "'kernel list'" <linux-kernel@vger.kernel.org>,
        "'James P. Ketrenos'" <ipw2100-admin@linux.intel.com>
In-Reply-To: <000f01c56dbf$9b15de90$600cc60a@amer.sykes.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Friday 10 June 2005 16:23, Alejandro Bonilla wrote:
> > Adding kernel level wireless autoconfiguration duplicates the effort.
> > Since I am not going to give up a requirement to be able to stay radio
> > silent at boot (me too wants freedom, not only you), you need to add
> > disable=1 module parameter to each driver, which adds to the mess.
> >
> > ALSA does the Right Thing. Sound is completely muted out at
> > module load.
> > It's a user freedom to set desired volume level after that.
> 
> Yeah right. I remember I had to google for 10 minutes to find the answer for
> this one. Why would you install something, for it to not work?
> 
> It thing of Mute in ALSA is stupid. If you want Sound, you install the Sound
> and enable it. Why would it make you google for more things to do? ALSA mute
> on install is WAY way, not OK.
> 
> You *will* have to use a How-To with ALSA, nobody knows that your sound
> would be off because some people decided it.

Well, which sound level shall be set instead? 100%? Maybe too loud for
my 500 watt loudpeakers, eh? 50%? Still too many. 5%? Nah.
My machine at work has a headphone which is anything but loud.
5% is nearly silence for it.

See? It's not a kernel matter at which volume sound must be set.
It is impossible to decide on the 'right' default.
 
> But this is out of the Topic. I agree with you all, but as I mentioned in a
> more current email, this is a laptop, not a server. Things behave
> differently and you want things faster. (Yes, I could have a script)

Or laptop oriented distro can have a script for you,
just like they already do have for DHCPizing all ifaces.

Not kernel business.

> What I'm saying, is that just as ALSA, you will have to google even more
> just to be able to look for the boot param for the driver for it to ASSOC on
> boot like the Original drive does. Instead, if you simply don't want to
> associate then turn off the Radio.
> 
> It's a simple FN+F2 or depends on your laptop.
> 
> Let's not make this a bigger thread, just decide and then do it that way.
> I'm looking at this on the side of a supporter, seeing the emails from
> users... "how do I make it behave as it was before" "it won't assoc on boot
> anymore"

Users which can not figure it by themself have not much power in dictating
how kernel drivers are written. Sure we listen to users, but we won't
blidly follow any and all suggestions.

If users want it different nodoby prohibits them from writing their own
drivers, right? Or patching existing ones, for that matter. Send patches to lkml
for discussion.
--
vda
