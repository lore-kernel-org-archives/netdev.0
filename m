From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- found another user with the same regression
Date: Thu, 21 Aug 2008 10:57:40 -0700
Message-ID: <86802c440808211057j41e2b0c8jcd0817ca047962d0@mail.gmail.com>
References: <198958.27259.qm@web82105.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Ingo Molnar" <mingo@elte.hu>, "Vivek Goyal" <vgoyal@redhat.com>,
	"Bill Fink" <billfink@mindspring.com>,
	linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"Peter Zijlstra" <peterz@infradead.org>,
	"Thomas Gleixner" <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: "David Witbrodt" <dawitbro@sbcglobal.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756941AbYHUR54@vger.kernel.org>
In-Reply-To: <198958.27259.qm@web82105.mail.mud.yahoo.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 21, 2008 at 9:53 AM, David Witbrodt <dawitbro@sbcglobal.net> wrote:
>
>
>> > I will try to provide the entire output tonight or tomorrow.  It will be
>> > difficult, though:  it looks like I have to try to fit the info from about
>> > 60 of the printk's in your patch onto the 80x25 VGA screen, and still
>> > make it understandable enough to be useful.
>> >
>>
>> with hpet=disable?
>
> Oh, well that's easy.  (See below.)  I assumed you needed the data for a
> hanging kernel, not one with the workaround enabled.
>
> I can still try to provide the output of the printk's in your patch later,
> in that would have any value.  Here is 'dmesg' for a recent kernel with
> "hpet=disable":

insert_resource/request_resource works well

can you verify if hpet work on old kernel?

cat /proc/timers*

YH
