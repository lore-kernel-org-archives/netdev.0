From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] isdn: hisax: l3dss1.c: Fix for possible null pointer
 dereference
Date: Tue, 20 May 2014 16:23:23 +0400
Message-ID: <537B493B.8020008@cogentembedded.com>
References: <1400534662-5729-1-git-send-email-rickard_strandqvist@spectrumdigital.se>	<537A771C.2050808@cogentembedded.com> <CAFo99gb3fOq=kXwiG=LsvRXHdgazQWv3t6XZqDOtRHc+FLxCbw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFo99gb3fOq=kXwiG=LsvRXHdgazQWv3t6XZqDOtRHc+FLxCbw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 20-05-2014 1:56, Rickard Strandqvist wrote:

> Hi  Sergei

> I did not put the assignment in the if statement.

    You didn't but you changed the line it's on (which wasn't required BTW).

> Is it meant for me
> to change all the code around the parts I fix?

    No, the patch just needs to be checkpatch.pl-clean.

> There are many assignments in if in the l3dss1_cmd_global() funktion.

    You can leave them alone for now. You can also leave alone the line I was 
referring to.

> It's late and I'm tired, but I still can not see which of these pairs
> of features that I can remove ...?

>              if (ic->parm.dss1_io.timeout > 0) {
>                  if (!(pc = dss1_new_l3_process(st, -1))) {
>                      free_invoke_id(st, id);
>                      return (-2);
>                  }
>                  pc->prot.dss1.ll_id = ic->parm.dss1_io.ll_id; /* remember id */
>                  pc->prot.dss1.proc = ic->parm.dss1_io.proc; /* and procedure */
>              }

    I didn't quite get the question, if you were asking me.

> Best regards
> Rickard Strandqvist

WBR, Sergei
