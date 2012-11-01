From: Bob Liu <lliubbo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH RFC net-next 2/4] bfin_mac: replace
 sys time stamps with raw ones instead.
Date: Thu, 1 Nov 2012 17:39:01 +0800
Message-ID: <CAA_GA1e_NkFq49abibVtcyOcGp+AnP=yLbNPxmD3SdaAbWp+Jw@mail.gmail.com>
References: <84396eacd75b4abed36a7819d8c2c33f9ced1ad5.1348851539.git.richardcochran@gmail.com>
	<CAA_GA1dWgav0fP3wJNFQW=VE9Qh-V8NBHqsmNoXaRny+5dnewg@mail.gmail.com>
	<20121030134112.GB2283@netboy.at.omicron.at>
	<CAA_GA1fW2zA2j66y7zfVe6+U-pb1=3mOyFFH+oDHimMFAXyH7Q@mail.gmail.com>
	<20121031083652.GC2327@netboy.at.omicron.at>
	<CAA_GA1cQojiaJat8gGmp3XYZVGOtKi2xoFS08hsYTGssdbWcRg@mail.gmail.com>
	<20121031124638.GA14197@netboy.at.omicron.at>
	<CAA_GA1eLXajk+wfwf7QYVoabDDeXLZecaTFX+6JRyoaYOyztQQ@mail.gmail.com>
	<20121101084111.GC2637@netboy.at.omicron.at>
	<CAA_GA1f=2ubb1z6rr1L8TR54cwh1NQcKiiaZqqv2r3mjX1wL7g@mail.gmail.com>
	<20121101093540.GB5949@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Miroslav Lichvar <mlichvar-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        John Ronciak <john.ronciak-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        device-drivers-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org,
        Jacob Keller <jacob.e.keller-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org,
        Patrick Ohly <patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
In-Reply-To: <20121101093540.GB5949-TJb37gCd1q6chkuNt9O67llkmcu1nq/N@public.gmane.org>
List-Unsubscribe: <https://blackfin.uclinux.org/mailman/options/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=unsubscribe>
List-Archive: <http://blackfin.uclinux.org/pipermail/uclinux-dist-devel>
List-Post: <mailto:uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
List-Help: <mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=help>
List-Subscribe: <https://blackfin.uclinux.org/mailman/listinfo/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=subscribe>
Sender: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
Errors-To: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 1, 2012 at 5:35 PM, Richard Cochran
<richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Thu, Nov 01, 2012 at 04:54:30PM +0800, Bob Liu wrote:
>>
>> date in master side is:
>> root:/> date
>> Thu Dec 21 01:34:26 UTC 2006
>> root:/>
>
> What is the time on the master from the 'testptp -g' command?
>
>> So the system time didn't sync.
>
> I guess that you need to set the PHC time on the master, using 'testptp -s'.
>
> [ There are always two clocks on each host, the Linux system time and
>   the PHC time in the hardware clock. ]
>

Thank you very much.
It works.

-- 
Regards,
--Bob
