From: Eamonn Hamilton <EAMONN.HAMILTON@saic.com>
Subject: Re: linux 2.6.9: r8169: eth0: PCI error (status: 0x8404). Device
	disabled.
Date: Thu, 21 Oct 2004 10:25:43 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098350743.15528.40.camel@ukabzc383.uk.saic.com>
References: <1098269117.6631.5.camel@ukabzc383.uk.saic.com>
	 <20041020121520.GA4004@electric-eye.fr.zoreil.com>
	 <1098282567.6631.10.camel@ukabzc383.uk.saic.com>
	 <20041020201010.GA13023@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20041020201010.GA13023@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Francois,

Many apologies for the top posting, I'm in an Outlook land and it's
given me bad habits :( ( mea culpa, mea culpa, mea maxima culpa, je
m'apologie :)

As you surmised, the card seems to work OK under moderate load, but
under havy transmit load the error occurs. It hasn't been seen under
Anyway, I now have 2.6.9 patched with the patch you sent with NAPI
enabled, 2.6.7 and 2.6.8 installed. I'm also going to install another
kernel with the code you mentioned commented out as follows, yes ?

if (unlikely(status & SYSErr)) {
   /* rtl8169_pcierr_interrupt(dev); */
   break;

You also mentioned being able to enable TX checksum and segmentation
offload - how do I enable this, is it through ethtool or something more
esoteric?

Thanks again for the help, hopefully I'll be able to get this lot tested
over the next couple of days and let you know how it went.

Cheers,
Eamonn
