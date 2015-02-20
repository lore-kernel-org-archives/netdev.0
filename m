From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 6/7 linux-next] wan: cosa: replace current->state by set_current_state()
Date: Fri, 20 Feb 2015 21:34:28 +0300
Message-ID: <54E77E34.6050909@cogentembedded.com>
References: <1424455977-21903-1-git-send-email-fabf@skynet.be> <1424455977-21903-6-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Jan \"Yenya\" Kasprzak" <kas@fi.muni.cz>, netdev@vger.kernel.org
To: Fabian Frederick <fabf@skynet.be>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424455977-21903-6-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 02/20/2015 09:12 PM, Fabian Frederick wrote:

> Use helper functions to access current->state.
> Direct assignments are prone to races and therefore buggy.

> current->state = TASK_RUNNING is replaced by __set_current_state()

    You sometimes use __set_current_state() and sometimes set_current_state().

> Thanks to Peter Zijlstra for the exact definition of the problem.

> Suggested-By: Peter Zijlstra <peterz@infradead.org>
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

[...]

WBR, Sergei
