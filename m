From: x z <dealup@yahoo.com>
Subject: Makefile for linux modules
Date: Fri, 29 Sep 2006 18:59:48 -0700 (PDT)
Message-ID: <20060930015948.31753.qmail@web52806.mail.yahoo.com>
References: <20060929182008.fee2a229.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422890AbWI3B7u@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
In-Reply-To: <20060929182008.fee2a229.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi
   I have a makefile to make several driver modules:
obj-$(CONFIG_FUSION_SPI)	+= mptbase.o mptscsih.o
mptspi.o
obj-$(CONFIG_FUSION_FC)		+= mptbase.o mptscsih.o
mptfc.o
obj-m				+= mptbase.o mptscsih.o mptsas.o
obj-$(CONFIG_FUSION_LAN)	+= mptlan.o
obj-m				+= mptctl.o
obj-m                           += mptcfg.o
obj-m                       +=mptstm.o


this will compile all modules and the modules can be
installed successfully.

I need to have a comfunc.c file, which contains all
common functions, which could be used by these module
files.
I added the line below to the content just below
mptstm.o (I tried adding just above mptlan). 
mptbase-objs             := comfunc.o

All modules are compiled successfully. I can install
mptbase.ko. However, when I try to install mptctl.ko
(or other modules), I got errors like mptctl: Unknown
symbol mpt_register; mpt_deregister. These functions
are implemented in mptbase.c.

How do I fix this problem?

thanks
Robert


__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 
