From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sh_eth: move inline functions to the header file
Date: Tue, 07 Apr 2015 20:21:23 +0300
Message-ID: <55241213.50200@cogentembedded.com>
References: <4254119.qJUdUQCUqs@wasted.cogentembedded.com> <CAMuHMdWS05eOT11prYaVddGwUjGCEDHfd=kn7JYv73HKw0s2BQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdWS05eOT11prYaVddGwUjGCEDHfd=kn7JYv73HKw0s2BQ@mail.gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 04/07/2015 04:21 PM, Geert Uytterhoeven wrote:

>> The explicitly inline functions belong to the header files, so move
>> cpu_to_edmac() and edmac_to_cpu() into the driver header.

> Why do they belong in the header file?

    Because they're explicitly *inline*. The functions in the .c file 
shouldn't have the *inline* keyword, DaveM wants us to rely on gcc's judgment.

> Are they (planned to be) used by
> another source file (EtherAVB?)?

    No.

> Currently no other source file besides sh_eth.c includes sh_eth.h, so
> IMHO sh_eth.h could just be absorbed by sh_eth.c.

    I agree, in principle.

[...]

>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

> Gr{oetje,eeting}s,
>                          Geert

WBR, Sergei

