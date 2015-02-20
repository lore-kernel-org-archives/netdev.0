From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 6/7 linux-next] wan: cosa: replace current->state by set_current_state()
Date: Fri, 20 Feb 2015 22:15:03 +0300
Message-ID: <54E787B7.5000609@cogentembedded.com>
References: <1424455977-21903-1-git-send-email-fabf@skynet.be> <1424455977-21903-6-git-send-email-fabf@skynet.be> <54E77E34.6050909@cogentembedded.com> <1849761882.58117.1424458263796.open-xchange@webmail.nmp.proximus.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org, "Jan \"Yenya\" Kasprzak" <kas@fi.muni.cz>
To: Fabian Frederick <fabf@skynet.be>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1849761882.58117.1424458263796.open-xchange@webmail.nmp.proximus.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/20/2015 09:51 PM, Fabian Frederick wrote:

>>> Use helper functions to access current->state.
>>> Direct assignments are prone to races and therefore buggy.

>>> current->state = TASK_RUNNING is replaced by __set_current_state()

>>       You sometimes use __set_current_state() and sometimes set_current_state().

> Hello Sergei,

> Peter suggested to use __set_current_state() for TASK_RUNNING :
> http://marc.info/?l=linux-kernel&m=142442259719216&w=2

    I didn't even question your decisions, I (like Peter) just wanted a more 
coherent change-log. Thanks to Peter for the explanations though. :-)

> Regards,
> Fabian

>>> Thanks to Peter Zijlstra for the exact definition of the problem.

>>> Suggested-By: Peter Zijlstra <peterz@infradead.org>
>>> Signed-off-by: Fabian Frederick <fabf@skynet.be>

>> [...]

WBR, Sergei
