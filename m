From: Shawn Landden <shawnlandden@gmail.com>
Subject: Re: AF_ALG buggy with sendfile
Date: Sun, 24 Nov 2013 14:04:14 -0800
Message-ID: <CAJusiZVxBg7=GX1-gQjXyyXznKvAnv26EWzVFu59+TBm5mGRsA@mail.gmail.com>
References: <CAJusiZVq3O1rok20HyYaoJDWxjtBdvMbDtjCif+sCyKPzpXMNA@mail.gmail.com>
	<CAJusiZXN4dOxg9S4ZiCziVXfNZ+=yu7a=84vUikV2RhbhYU7QA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	linux-crypto@vger.kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <CAJusiZXN4dOxg9S4ZiCziVXfNZ+=yu7a=84vUikV2RhbhYU7QA@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If you build https://kernel.googlesource.com/pub/scm/network/connman/connman/+/0.80/tools/alg-test.c
from the connman source code and compare the output to coreutils
sha1sum you can see the problem.

shawn@debian-T61:~/git/test$ make connman_afalg
cc     connman_afalg.c   -o connman_afalg
shawn@debian-T61:~/git/test$ ./connman_afalg /bin/true
send 27080 bytes
recv 20 bytes
45384483cf9cd0d82eba164131795b4807c6d39d  /bin/true
shawn@debian-T61:~/git/test$ sha1sum /bin/true
82667ba2ec681d8e55b0ee3b6db2970f9911680d  /bin/true

On Sun, Nov 24, 2013 at 2:00 PM, Shawn Landden <shawnlandden@gmail.com> wrote:
> heres a version of the test case that builds.....
>
> Sorry about that.
>
> On Sun, Nov 24, 2013 at 9:21 AM, Shawn Landden <shawnlandden@gmail.com> wrote:
>> If I use sendfile() to send to a accept()ed AF_ALG socket set up for
>> "hash", I get the wrong
>> answer, if I read() and then write() I get the right answer. None of
>> the system calls return an error.
>>
>> test case attached.
>>
>> --
>>
>> ---
>> Shawn Landden
>> +1 360 389 3001 (SMS preferred)
>
>
>
> --
>
> ---
> Shawn Landden
> +1 360 389 3001 (SMS preferred)



-- 

---
Shawn Landden
+1 360 389 3001 (SMS preferred)
