From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: [PATCH] build some drivers only when compile-testing
Date: Wed, 19 Jun 2013 09:12:56 +0200
Message-ID: <51C159F8.8090604@suse.cz>
References: <1369214326-6558-1-git-send-email-jslaby@suse.cz> <20130523022327.GB6159@kroah.com> <519D8876.9050405@suse.com> <51BF6BFF.7050705@suse.cz> <51C1595D.60706@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Mahoney <jeffm@suse.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	jirislaby@gmail.com, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	linux-usb@vger.kernel.org,
	Florian Tobias Schandinat <FlorianSchandinat@gmx.de>,
	linux-geode@lists.infradead.org, linux-fbdev@vger.kernel.org,
	Richard Cochran <richardcochran@gmail.com>,
	netdev@vger.kernel.org, Ben Hutchings <ben@decadent.org.uk>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>,
	Michal Marek <mmarek@suse.cz>
To: Tomi Valkeinen <tomi.valkeinen@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51C1595D.60706@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/19/2013 09:10 AM, Tomi Valkeinen wrote:
> On 17/06/13 23:05, Jiri Slaby wrote:
> 
>> The last point I inclined to the Greg's argument to remove the
>> EXPERT dependency.
>> 
>> So currently I have what is attached... Comments?
> 
> The patch looks a bit odd with the USB_CHIPIDEA_IMX parts. You're
> not adding COMPILE_TEST there, but you're adding a totally new
> config option, and also changing the Makefile.

Look:

+config USB_CHIPIDEA_IMX
+       bool "ChipIdea IMX support"
+       depends on OF_DEVICE && (ARM || COMPILE_TEST)

COMPILE_TEST added here ----------------^^^^^^^^^^^^

-- 
js
suse labs
