From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH v10 05/11] seccomp: add system call filtering using BPF
Date: Wed, 22 Feb 2012 17:07:05 -0800
Message-ID: <4F459139.8010603@zytor.com>
References: <1329845435-2313-1-git-send-email-wad@chromium.org> <1329845435-2313-5-git-send-email-wad@chromium.org> <38d58caa17befe422065efe5dc451a34.squirrel@webmail.greenhost.nl> <1329920626.3258.174.camel@deadeye> <CABqD9hYRPQbAY2KejstrutEO_jXU3QgBB9og_ByAaFcXZx4GHg@mail.gmail.com> <60d94ae06f380ff088f6270c3a536ee9.squirrel@webmail.greenhost.nl> <CAObL_7H14aPuaMjSyoaxWxWzP_=9D1yDiO0EKk9LPi_8-GYeyw@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Indan Zupancic <indan@nul.nu>, Will Drewry <wad@chromium.org>,
        Ben Hutchings <bhutchings@solarflare.com>,
        linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
        linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
        netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
        davem@davemloft.net, mingo@redhat.com, oleg@redhat.com,
        peterz@infradead.org, rdunlap@xenotime.net, mcgrathr@chromium.org,
        tglx@linutronix.de, eparis@redhat.com, serge.hallyn@canonical.com,
        djm@mindrot.org, scarybeasts@gmail.com, pmoore@redhat.com,
        akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
        markus@chromium.org, keescook@chromium.org
To: Andrew Lutomirski <luto@mit.edu>
Return-path: <kernel-hardening-return-929-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAObL_7H14aPuaMjSyoaxWxWzP_=9D1yDiO0EKk9LPi_8-GYeyw@mail.gmail.com>
List-Id: netdev.vger.kernel.org

On 02/22/2012 03:51 PM, Andrew Lutomirski wrote:
> On Wed, Feb 22, 2012 at 3:46 PM, Indan Zupancic <indan@nul.nu> wrote:
>> On Wed, February 22, 2012 20:47, Will Drewry wrote:
>>> On Wed, Feb 22, 2012 at 8:23 AM, Ben Hutchings
>>>> I would have thought the way to make sure the architecture is always
>>>> checked is to pack it together with the syscall number.
>>
>> I missed that suggestion, putting the syscall number and arch in one
>> data field would indeed make it harder to not check the arch.
> 
> Is there enough room?  On x86-64 at least, rax could conceivably be
> extended to 64 bits some day.  Bit 30 is already spoken for by x32.
> 

No it couldn't, because we mask off the high 32 bits and thus it could
(theoretically) break user space.

	-hpa


-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.
