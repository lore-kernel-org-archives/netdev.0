From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Implementation for IPv6 MIB:ipv6AddressTable
Date: Wed, 8 Oct 2003 13:00:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031008130016.559b8047.davem@redhat.com>
References: <OF4B7AD7E2.5CA239A1-ON87256DB9.0067C527@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mashirle@us.ibm.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Shirley Ma <xma@us.ibm.com>
In-Reply-To: <OF4B7AD7E2.5CA239A1-ON87256DB9.0067C527@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 8 Oct 2003 11:55:49 -0700
Shirley Ma <xma@us.ibm.com> wrote:

> I think it's better to define MAX_JIFFIES unsigned long.
> 
> #define MAX_JIFFIES (~0UL)
> 
> Should I resent the whole patch again?

I think this is still incorrect, MAX_JIFFIES is "(~0UL >> 1)"
