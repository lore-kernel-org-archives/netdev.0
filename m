From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH] x86: Wire up 32-bit direct socket calls
Date: Tue, 15 Sep 2015 13:55:28 -0700
Message-ID: <55F885C0.7080309@zytor.com>
References: <cb5138299d37d5800e2d135b01a7667fa6115854.1436912629.git.luto@kernel.org>
 <49726621.LPTnfQXYGz@wuerfel>
 <CAMuHMdXX31xZ4AS6FbeXLXgDn5UV5=0C3hrihuwDOP_abuJsBg@mail.gmail.com>
 <2108882.tTxglVCXxY@wuerfel>
 <CALCETrVbNs-bOfr8cC3CC2RrBtKctdw4d0o9Ds6RQfXEm466YQ@mail.gmail.com>
 <20150914133500.GA385@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Tulio Magno Quites Machado Filho
	<tuliom@linux.vnet.ibm.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Alexander Larsson <alexl@redhat.com>,
	Cosimo Cecchi <cosimo@endlessm.com>,
	Dan Nicholson <nicholson@endlessm.com>,
	libc-alpha <libc-alpha@sourceware.org>,
	Rajalakshmi Srinivasaraghavan <raji@linux.vnet.ibm.com>,
	Linux-Arch <linux-arch@vger.kernel.org>
To: Ingo Molnar <mingo@kernel.org>,
	Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20150914133500.GA385@gmail.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/14/2015 06:35 AM, Ingo Molnar wrote:
>>
>> I missed sys_ipc entirely.
>>
>> Ingo, Thomas, want to just wire those up, too?  I can send a patch
>> next week, but it'll be as trivial as the socket one.
> 
> Yeah, sure - split out system calls are so much better (and slightly faster) than 
> omnibus demuxers.
> 

Indeed.  sys_socketcall and sys_ipc are legacy mistakes.

	-hpa
