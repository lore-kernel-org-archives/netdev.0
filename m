From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] [IPV6] Fixed multiple mistake extension header handling
Date: Mon, 14 Apr 2003 11:20:49 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030414.112049.05124201.davem@redhat.com>
References: <20030415.032109.127483264.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20030415.032109.127483264.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Tue, 15 Apr 2003 03:21:09 +0900 (JST)

    - double free if sending Parameter Problem message in reassembly code.
    - (sometimes) broken checksum
    - HbH not producing unknown header; it is only allowed at the beginning of
      the exthdrs chain.
    - wrong pointer value in Parameter Problem message.
   
   I've fixed the problem.
   
   Patch is against 2.5.67 + CS 1.1202.

Patch applied, thank you very much.
