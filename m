From: John Ronciak <john.ronciak@gmail.com>
Subject: Re: My vote against eepro* removal
Date: Thu, 19 Jan 2006 09:16:50 -0800
Message-ID: <56a8daef0601190916v463d06edp23bbe0b849f81217@mail.gmail.com>
References: <AAD6DA242BC63C488511C611BD51F367323322@MAILIT.keba.co.at>
	 <20060119162056.GP19398@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: kus Kusche Klaus <kus@keba.com>, Lee Revell <rlrevell@joe-job.com>,
	linux-kernel@vger.kernel.org, john.ronciak@intel.com,
	ganesh.venkatesan@intel.com, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932436AbWASRQw@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20060119162056.GP19398@stusta.de>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

During the watchdog the e100 driver reads all of the status registers
from the actual hardware.  There are 26 (worst case) register reads. 
There is also a spin lock for another check in the watchdog.  It would
still surprise me that all of this would take 500 usec.  If you are
seeing this delay, you can comment out the scheduling of the watchdog
to see if this goes away.  We'll need to narrow down exactly what in
the watchdog is causing the delay

Thanks.

--
Cheers,
John
