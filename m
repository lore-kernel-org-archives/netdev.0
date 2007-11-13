From: Mark Lord <liml@rtr.ca>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 18:37:21 -0500
Message-ID: <473A3531.3030509@rtr.ca>
References: <32209efe0711122242m3a5f081asf1c11a38b24db10c@mail.gmail.com> <20071113031553.3c7b5c16.akpm@linux-foundation.org> <4739ADA2.4060604@rtr.ca> <alpine.LFD.0.9999.0711131521590.3265@localhost.localdomain> <4739E4E5.2010602@rtr.ca> <alpine.LFD.0.9999.0711132345480.3265@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
	linux-pcmcia@lists.infradead.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	bugme-daemon@bugzilla.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <owner-linux-input@atrey.karlin.mff.cuni.cz>
In-Reply-To: <alpine.LFD.0.9999.0711132345480.3265@localhost.localdomain>
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org

Thomas Gleixner wrote:
> On Tue, 13 Nov 2007, Mark Lord wrote:
> 
>> Thomas Gleixner wrote:
>>> On Tue, 13 Nov 2007, Mark Lord wrote:
>>>
>>>>> Andrew Morton wrote:
>>>>>>> On Mon, 12 Nov 2007 22:42:32 -0800 "Natalie Protasevich"
>>>>>>> <protasnb@gmail.com> wrote:
>>>>> ..
>>>>>>>>> with CONFIG_NO_HZ and/or CONFIG_HPET_TIMER set kernel 2.6.23
>>>>>> doesn't
>>>>>>>>> boot (ARM, Timer)
>>>>>>>>> http://bugzilla.kernel.org/show_bug.cgi?id=9229
>>>>>>>>> Kernel: 2.6.23
>>>>>>>>> No response from developers
>>>>> ..
>>> The bug report is bogus. ARM has no CONFIG_HPET_TIMER.  
>>>>> Note:  that same bug exists/existed on i386 back when NO_HZ was
>>>>> introduced (2.6.21?).  I still see it from time to time on my Quad core
>>>>> system (very rare), but not any more on my Duo notebook where it used
>>>>> to happen about 1 in n boots (n < 10).
>>>>>> AFAICT no fix was ever released for it.
>>> Hmm, at which point does the boot stop ? 
>> ..
>>
>> Just as it prints out these messages, sometimes one of them,
>> sometimes both (or all four on the quad core):
>>
>> kernel: switched to high resolution mode on cpu 1
>> kernel: switched to high resolution mode on cpu 0 
> 
> It's completely dead afterwards ?

Yeah.  No magic sysrq key or anything.
There's gotta be a race somewhere that's causing it,
but it's not obvious where to look for it.

My regular 2-core notebook no longer suffers from it,
and subtle .config changes used to make it come and go
back when it first appeared.

The quad-core has only done it twice on me thus far.

Tracking this one down looks tricky.  It might require some early lockup
detection code to be tailor made or something.

Cheers
