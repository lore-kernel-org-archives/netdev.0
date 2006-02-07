From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: e100 oops on resume
Date: Tue, 07 Feb 2006 01:57:07 -0500
Message-ID: <43E844C3.5080500@pobox.com>
References: <20060124225919.GC12566@suse.de>	 <20060124232142.GB6174@inferi.kami.home>	 <20060125090240.GA12651@suse.de> <20060125121125.GH5465@suse.de>	 <4807377b0601251137r7621216byc47b03a3c634557c@mail.gmail.com>	 <4807377b0601251628k4227dad0ld731f2c25c211b91@mail.gmail.com>	 <20060126190236.GA12481@suse.de>	 <20060128115335.GA4511@inferi.kami.home> <4807377b0601281153r618586ddhca27b7772e023d26@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stefan Seyfried <seife@suse.de>, Olaf Kirch <okir@suse.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964984AbWBGG5R@vger.kernel.org>
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
In-Reply-To: <4807377b0601281153r618586ddhca27b7772e023d26@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesse Brandeburg wrote:
> On 1/28/06, Mattia Dongili <malattia@linux.it> wrote:
> 
>>On Thu, Jan 26, 2006 at 08:02:37PM +0100, Stefan Seyfried wrote:
>>
>>>On Wed, Jan 25, 2006 at 04:28:48PM -0800, Jesse Brandeburg wrote:
>>>
>>>
>>>>Okay I reproduced the issue on 2.6.15.1 (with S1 sleep) and was able
>>>>to show that my patch that just removes e100_init_hw works okay for
>>>>me.  Let me know how it goes for you, I think this is a good fix.
>>>
>>>worked for me in the Compaq Armada e500 and reportedly also fixed the
>>>SONY that originally uncovered it.
>>
>>confirmed here too. The patch fixes S3 resume on this Sony (GR7/K)
>>running 2.6.16-rc1-mm3.
> 
> 
> excellent news! thanks for testing.
> 
> Jeff, could you please apply to 2.6.16-rcX
> 
> Jesse

SIGH.  In your last patch submission you had it right, but Intel has yet 
again regressed in patch submission form.

Your fixes will be expedited if they can be applied by script, and then 
quickly whisked upstream to Linus/Andrew.  This one had to be applied by 
hand (so yes, its applied) for several reasons:

* Unreviewable in mail reader, due to MIME type application/octet-stream.

* In general, never use MIME (attachments), they decrease the audience 
that can easily review your patch.

* Your patch's description and signed-off-by were buried inside the 
octet-stream attachment.

* Please review http://linux.yyz.us/patch-format.html  (I probably 
should add MIME admonitions to that)

	Jeff
