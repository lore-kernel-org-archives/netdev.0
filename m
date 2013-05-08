From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: Linux driver for Realtek RTL8723AU devices with USB ID 0bda:1724
 such as found in Lenovo IdeaPad Yoga 13
Date: Tue, 07 May 2013 19:32:25 -0700
Message-ID: <5189B939.4010905@zytor.com>
References: <5159B52D.3050601@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Dan Williams <dcbw@redhat.com>,
	"'George0505'" <george0505@realtek.com>,
	Joon Ro <joonhyoung.ro@gmail.com>,
	Greg KH <gregkh@linux-foundation.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5159B52D.3050601@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/01/2013 09:26 AM, Larry Finger wrote:
> 
> My plan is to evolve this driver into a form that is suitable for
> inclusion in the staging tree of the kernel; however, that will take
> some effort and time, which is why I am making the intermediate results
> available now. As that work proceeds, the git version will evolve into
> code that can be submitted to the kernel with only small changes.
> 
> Please be aware that I do not have any hardware that uses this driver,
> thus I can only guarantee that the code compiles; however, Joon Ro has
> tested the driver and he assures me that it works. Together we have been
> eliminating spurious log entries.
> 
> The 8723a chip also includes Bluetooth hardware. I have not received any
> indication that it is active in the RTL8723AU, but it certainly is in
> the RTL8723AE, the PCIe version. In a separate activity, I am working
> with Realtek to prepare a kernel driver for this portion of the device.
> 

So I can verify that this driver works against 3.8.11 (not against
current -linus because of a build failure), and yes, there is Bluetooth
in this device.  In fact, it seems to work better than some in-tree
drivers I have seen in the past.

However, I'm confused as to the above and what it implies for the
purpose of the staging tree.  Wasn't the whole point of the staging tree
to have a working-but-ugly driver upstream and have the work to clean it
up happen in the mainline tree instead of off somewhere.

	-hpa
