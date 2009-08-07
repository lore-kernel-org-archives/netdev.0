From: Alan Jenkins <sourcejedi.lkml@googlemail.com>
Subject: Re: [PATCH 2/7 v3] initdev:kernel:USB init device discovery notification
Date: Fri, 07 Aug 2009 21:09:40 +0100
Message-ID: <4A7C8A04.3060005@googlemail.com>
References: <9b2b86520908070832p2d1658b0t8b1d89d1a034bb9a@mail.gmail.com> <Pine.LNX.4.44L0.0908071142260.3063-100000@iolanthe.rowland.org> <9b2b86520908071017h606e595fr4488d6ff61cb337c@mail.gmail.com> <20090807174209.GB30450@cuplxvomd02.corp.sa.net>
Reply-To: alan-jenkins@tuffmail.co.uk
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Alan Stern <stern@rowland.harvard.edu>,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	linux-usb@vger.kernel.org, greg@kroah.com,
	linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	arjan@infradead.org
To: David VomLehn <dvomlehn@cisco.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090807174209.GB30450@cuplxvomd02.corp.sa.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David VomLehn wrote:
> On Fri, Aug 07, 2009 at 06:17:51PM +0100, Alan Jenkins wrote:
>   
>> On 8/7/09, Alan Stern <stern@rowland.harvard.edu> wrote:
>>     
>>> On Fri, 7 Aug 2009, Alan Jenkins wrote:
>>>
>>>       
>>>>> +/* The mask of possible USB boot devices depends on what drivers and
>>>>> + * options have been configured into the kernel.  There are too many
>>>>> + * USB network config options to list here, so just assume it is always
>>>>> + * possible to have a USB network device.
>>>>> + */
>>>>>           
>>>> That could be fixed though.  Make the "USB Network Adaptors" menu into
>>>> an option.

> I remember thinking about this and seem to recall that Alan Stern and I
> tossed this idea around, but didn't act on it. Such a thing holds potential
> for avoiding an unnecessary delay during boot. Whether it actually makes
> things faster in a given configuration will depend on that configuration's
> critical path, but I would welcome such a patch on the basis that it's
> unlikely to hurt and could improve boot times in some circumstances.
>   

Bother, I see why this doesn't work now.  There are all the USB
*wireless* network drivers outside the menu.

Thanks anyway
Alan
