From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH]snmp6 64-bit counter support in proc.c
Date: Thu, 22 Jan 2004 21:26:51 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401221826.VAA16255@yakov.inr.ac.ru>
References: <OF1837C6DA.A9CB8829-ON87256E22.006C142B@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com (David S. Miller), mashirle@us.ibm.com,
        kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: xma@us.ibm.com (Shirley Ma)
In-Reply-To: <OF1837C6DA.A9CB8829-ON87256E22.006C142B@us.ibm.com> from "Shirley Ma" at ñÎ× 21, 2004 11:45:30 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> Did you hear different voices?

Here is a little warning. It will give corrupt values on 32 bit archs
when update with 32 bit overflow happens while value is folded.

To do 64 bit arithmetics you need either to serialize reader wrt writer
or to do some funny tricks with detecting overflows while reading and
special sequence of operations at update with proper barriers, which
will be reflected in performance anyway. Essentially, this haemorhoids
is the reason why they stayed 32 bit.

Alexey
