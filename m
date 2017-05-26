From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH 1/5] MIPS: Optimize uasm insn lookup.
Date: Fri, 26 May 2017 11:25:14 -0700
Message-ID: <f4472a45-a67b-763f-fffc-26fdc9fa27b4@caviumnetworks.com>
References: <20170526003826.10834-1-david.daney@cavium.com>
 <20170526003826.10834-2-david.daney@cavium.com>
 <c8d6691a-0c17-eab7-ac34-efc4e18589b9@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Matt Redfearn <matt.redfearn@imgtec.com>,
        David Daney <david.daney@cavium.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
        ralf@linux-mips.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c8d6691a-0c17-eab7-ac34-efc4e18589b9@imgtec.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/26/2017 01:07 AM, Matt Redfearn wrote:
[...]
>> -    { insn_lwx, 0, 0 },
>> -    { insn_ldx, 0, 0 },
>> -    { insn_invalid, 0, 0 }
>> +static struct insn insn_table_MM[insn_invalid] = {
> 
> ^ You could make this const too, like you have the one in uasm-mips.c.
> 

Good catch.  I meant to do that.

I will fix it for the next revision of the patch set.



> Thanks,
> Matt
> 
