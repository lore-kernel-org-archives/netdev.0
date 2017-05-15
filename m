From: Eric Dumazet <edumazet@google.com>
Subject: Re: stable/linux-4.10.y build: 203 builds: 3 failed, 200 passed, 3
 errors, 5 warnings (v4.10.16)
Date: Mon, 15 May 2017 06:57:51 -0700
Message-ID: <CANn89iJEsM9xYC6boSMkJW6MfL1HoUzVNc8ov_Lvi=qi=mHJpg@mail.gmail.com>
References: <5918603a.118d1c0a.d6026.6b1a@mx.google.com> <CAK8P3a2gFXScsizfvd-2=yEWBvPoE7L-r5CCf63MzPuWejPzAQ@mail.gmail.com>
 <CANn89iKvCk5C6btBbXh1kYpq2GcyW=6NADDGKH1ULeUbF9ddKA@mail.gmail.com> <CAK8P3a0XjehCE07iPkQM2sWG9AavZXw+T4s4YCJQ_JoF24-o1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "kernelci.org bot" <bot@kernelci.org>,
        Kernel Build Reports Mailman List
        <kernel-build-reports@lists.linaro.org>,
        gregkh <gregkh@linuxfoundation.org>, stable@vger.kernel.org,
        Networking <netdev@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <CAK8P3a0XjehCE07iPkQM2sWG9AavZXw+T4s4YCJQ_JoF24-o1A@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 15, 2017 at 6:55 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Mon, May 15, 2017 at 3:39 PM, Eric Dumazet <edumazet@google.com> wrote:
>> On Mon, May 15, 2017 at 5:57 AM, Arnd Bergmann <arnd@arndb.de> wrote:
>>> On Sun, May 14, 2017 at 3:48 PM, kernelci.org bot <bot@kernelci.org> wrote:
>>>
>>>  int sock_setsockopt(struct socket *sock, int level, int op,
>>>
>>> This commit is not marked 'Cc: stable' upstream, but is referenced
>>> in the one that was backported and looks like it might be appropriate
>>> for stable as well. Eric, can you clarify?
>>>
>>
>> Hi Arnd
>>
>> Yes, it looks like stable would need this small extract from 158f323b9868,
>> removing the parameter from sock_edemux macro
>
> Ok, and the rest of 158f323b9868 should not go into stable, right?
>

I do not believe this is a stable candidate.

A stable candidate coming from me would have a Fixes: tag
