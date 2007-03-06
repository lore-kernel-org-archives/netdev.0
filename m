From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [RFC] div64_64 support II
Date: Tue, 06 Mar 2007 10:48:57 -0800
Message-ID: <45EDB799.5080509@zytor.com>
References: <20070226143127.5c74bec9@freekitty> <p73slcnawh3.fsf@bingen.suse.de> <20070305155714.3abe1b5e@freekitty> <20070305.162551.41660347.davem@davemloft.net> <20070306140412.GA1470@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	shemminger@linux-foundation.org, jengelh@linux01.gwdg.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S966016AbXCFStt@vger.kernel.org>
In-Reply-To: <20070306140412.GA1470@one.firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
>> The problem with these algorithms that tradoff one or more
>> multiplies in order to avoid a divide is that they don't
>> give anything and often lose when both multiplies and
>> divides are emulated in software.
> 
> Actually on rereading this: is there really any Linux port
> that emulates multiplies in software? I thought that was only
> done on really small microcontrollers or smart cards; but anything
> 32bit+ that runs Linux should have hardware multiply, shouldn't it?

SPARC < v8 does multiplies using an MSTEP instruction.

	-hpa
