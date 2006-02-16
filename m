From: Jan-Frode Myklebust <mykleb@no.ibm.com>
Subject: Re: KERNEL: assertion (!sk->sk_forward_alloc) failed
Date: Thu, 16 Feb 2006 22:02:48 +0100
Message-ID: <slrndv9q3o.pib.mykleb@99RXZYP.ibm.com>
References: <e282236e0602070146p1ed3fdb6k74aa75e15bbc37a3@mail.gmail.com> <4807377b0602081207s7604eceahb8bf4af6715a6534@mail.gmail.com> <43EB9548.9060504@kernelpanic.ru> <cbec11ac0602091125w5a5a7c6em8462131e9f9b24dc@mail.gmail.com> <43EB98B0.4@kernelpanic.ru>
Cc: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964794AbWBPVLX@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2006-02-09, Boris B. Zhmurov <bb@kernelpanic.ru> wrote:
>
>> Is it possible for you to download 2.6.16-rc2 or similar and see if it
>> goes away?
>
> It'll be better, if I get only patch fixs that problem, not all 2.6.16-rc2.

I just got this same warning on a system running 2.6.14.5. It's been
up for 50 days, quite heavily loaded, and I've seen this only once. 
Should i be conserned ? Could someone tell me what it means ?

# uname -a
Linux mail 2.6.14.5 #1 SMP Tue Dec 27 14:39:55 CET 2005 i686 i686 i386 GNU/Linux
# dmesg|grep KERNEL
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/core/stream.c (279)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (148)
# ethtool -k eth0
Offload parameters for eth0:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: on
# ethtool -k eth1
Offload parameters for eth1:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: on


  -jf
