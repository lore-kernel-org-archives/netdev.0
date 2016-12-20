From: Josef Bacik <jbacik@fb.com>
Subject: Re: kernel/bpf/verifier.c: 4 * possible unintended fallthrough ?
Date: Tue, 20 Dec 2016 13:28:43 -0500
Message-ID: <1482258523.24490.10@smtp.office365.com>
References: <VI1PR08MB102286884ADF02FB45C203109C900@VI1PR08MB1022.eurprd08.prod.outlook.com>
        <CAADnVQ+_2D9ExoyiDbMFUNk0KSMQVYQSND+eca0O3r_fku1L2g@mail.gmail.com>
        <VI1PR08MB10228EE1E2FA0EBFEA78DE919C900@VI1PR08MB1022.eurprd08.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        "ast@kernel.org" <ast@kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Binderman <dcb314@hotmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <VI1PR08MB10228EE1E2FA0EBFEA78DE919C900@VI1PR08MB1022.eurprd08.prod.outlook
        .com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 20, 2016 at 11:34 AM, David Binderman <dcb314@hotmail.com> 
wrote:
> 
> Hello there,
> 
>> From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
>> I've tried 4.9 and 5.2 and don't see this warning.
> 
> As expected - I used a development version of gcc.
> Latest released version is 6.2
> 
>> Is this 6.x gcc?
> 
> 7.0 would be more accurate.
> 
>> I suspect it will have such warnings all over the kernel.
> 
> Indeed it has hundreds, but the subject under discussion is file
> kernel/bpf/verifier.c.
> 
> I am still not sure if I have found a fallthrough bug or not.

You haven't, this is intended so is a useless warning.  Thanks,

Josef
