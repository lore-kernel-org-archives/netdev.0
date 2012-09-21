From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 3/3] ptp: derive the device name from the
 parent device
Date: Fri, 21 Sep 2012 20:40:35 +0200
Message-ID: <20120921184035.GF6129@netboy.at.omicron.at>
References: <cover.1348245523.git.richardcochran@gmail.com>
 <9f2ed4a62d52182eeab86ad3dca7f6feeb68368a.1348245523.git.richardcochran@gmail.com>
 <1348247965.2521.11.camel@bwh-desktop.uk.solarflarecom.com>
 <20120921173709.GB6129@netboy.at.omicron.at>
 <02874ECE860811409154E81DA85FBB5818BFF5B4@ORSMSX105.amr.corp.intel.com>
 <1348249258.2521.25.camel@bwh-desktop.uk.solarflarecom.com>
 <20120921181115.GE6129@netboy.at.omicron.at>
 <1348251783.2521.42.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Keller, Jacob E" <jacob.e.keller@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	"Vick, Matthew" <matthew.vick@intel.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:59828 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757369Ab2IUSkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 14:40:47 -0400
Received: by wibhi8 with SMTP id hi8so2494148wib.1
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2012 11:40:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1348251783.2521.42.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 21, 2012 at 07:23:03PM +0100, Ben Hutchings wrote:
> 
> I think what I'm still missing from you is some explanation of what the
> 'clock name' is meant to be used as - a type name, a unique identifier,
> a 'friendly name' for listing clocks in a user interface?

The original idea was a type/friendly kind of thing.

Imagine you are the admin of some random box that should run PTP. You
do 'cat /sys/class/ptp/ptp0/clock_name' and see "gianfar clock". Then
you think to yourself, "Excellent, I know that one, it works great,
and I can even get a PPS output."

But if you saw "IXP46X timer" then you would think, "Forget it, this
will never work."

That was the idea.

But before the ethtool thing came along, people started putting MAC
addresses in that string, and it continued even after the ethtool
method appeared. I wanted to correct the MAC abuses, but then I
thought you were concurring with putting some kind of semi-unique
device ID there.

I really don't care too much about the clock_name anyhow, because I
always know my own hardware. I don't mind changing it from type-string
or friendly-name to device ID, if people think that is more useful.

Thanks,
Richard
