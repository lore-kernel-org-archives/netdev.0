From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFC] wimax/i2400m: fixup completion handling for resetting
 a device
Date: Fri, 27 Mar 2015 20:19:08 +0300
Message-ID: <5515910C.8000107@cogentembedded.com>
References: <1426585774-24204-1-git-send-email-hofrat@osadl.org> <55096FA1.9030908@cogentembedded.com> <20150320074705.GB21852@opentech.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Nicholas Mc Guire <hofrat@osadl.org>,
	Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>,
	linux-wimax@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nicholas Mc Guire <der.herr@hofr.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150320074705.GB21852@opentech.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 03/20/2015 10:47 AM, Nicholas Mc Guire wrote:

    Sorry for late reply, I'm pretty busy these days.

>>> wait_for_completion_timeout return 0 (timeout) or >=1 (completion) so the check
>>> for > 0 in the else branch is always true and can be dropped. The comment seems
>>> misleading as it is always going to pass the result up.

>>> The sync of the completion access with __i2400m_dev_reset_handle (which checks
>>> for   if (i2400m->reset_ctx)   could race if i2400m_reset() returns negative so
>>> the resetting of i2400m->reset_ctx == NULL is moved to the out: path.

>>> As wait_for_completion_timeout returns unsigned long not int, an appropriately
>>> named variable of type unsigned long is added and assignments fixed up.

>>     Don't try to do several things in one patch.

> normaly yes - this was marked as RFC and if I had split it up into
> 3 patches it would be hard to see how it fits together without
> actually applying them.

    You could summarize your intent in the cover letter (PATCH #0).

> The intent was to get feedback notably on moving i2400m->reset_ctx == NULL
> and if dropping the (I think missleading) comment about negative return is ok

> Should this be in seperate patches even as RFC ?

    I think the RFC patches should still conform to all the usual patch rules. 
How would we understand whether you intent to split the patch up later, if you 
didn't even write about it anywhere?

[...]

WBR, Sergei
