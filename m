From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]snmp6 64-bit counter support in proc.c
Date: Thu, 22 Jan 2004 16:35:04 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040122.163504.74739809.davem@redhat.com>
References: <OFA2457112.0F3CBC9D-ON88256E23.007C851A@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, mashirle@us.ibm.com, netdev@oss.sgi.com,
        xma@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kumarkr@us.ibm.com
In-Reply-To: <OFA2457112.0F3CBC9D-ON88256E23.007C851A@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Krishna Kumar <kumarkr@us.ibm.com>
   Date: Thu, 22 Jan 2004 14:50:15 -0800
   
   Isn't memory barrier used to stop re-ordering of instructions and needs to
   be present in both reader as well as writer to have synchronization
   since mb is for the CPU on which it is executing ?

You are correct.

Good thing I delayed this for a release, now we can work on
making sure we get this right. :-)
