From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 1/1] Bluetooth: hidp: Add support for hidraw
 HIDIOCGFEATURE  and HIDIOCSFEATURE
Date: Fri, 09 Jul 2010 05:01:37 -0300
Message-ID: <1278662497.10421.94.camel@localhost.localdomain>
References: <1276467601-9066-1-git-send-email-alan@signal11.us>
	 <1278623485.10421.73.camel@localhost.localdomain>
	 <4C369CDC.9080104@signal11.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David S Miller <davem@davemloft.net>,
	Jiri Kosina <jkosina@suse.cz>,
	Michael Poole <mdpoole@troilus.org>,
	Bastien Nocera <hadess@hadess.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Alan Ott <alan@signal11.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C369CDC.9080104@signal11.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Alan,

> > I looked at this and I am bit worried that this should not be done in
> > this detail in the HIDP driver. Essentially HIDP is a pure transport
> > driver. It should not handle all these details. Can we make this a bit
> > easier for the transport drivers to support such features?
> 
> I put these changes (most notably the addition of hidp_get_raw_report()) 
> in hidp because that's where the parallel function 
> hidp_output_raw_report() was already located. I figured the input should 
> go with the output. That said, if there's a better place for both of 
> them (input and output) to go, let me know where you think it should be, 
> and I'll get them moved into the proper spot.
> 
> I'm not sure what you mean about HIDP being a pure transport driver.

what is usb-hid.ko doing here? I would expect a bunch of code
duplication with minor difference between USB and Bluetooth.

Regards

Marcel
