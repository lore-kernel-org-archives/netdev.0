From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][IPV6] fix ipv6 header handling of AH input.
Date: Sun, 15 Jun 2003 06:15:00 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030615.061500.78718230.davem@redhat.com>
References: <20030615220632.0701a5cd.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, usagi@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kazunori@miyazawa.org
In-Reply-To: <20030615220632.0701a5cd.kazunori@miyazawa.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Kazunori Miyazawa <kazunori@miyazawa.org>
   Date: Sun, 15 Jun 2003 22:06:32 +0900

   This patch fixes ipv6 header handling of ah input and moves
   the routine to clear mutable options.
   It reduces unnecessary header clearing when a packet has only ESP.
   
   This patch for linux-2.5.70 + CS1.1307

Thank you very much, I have applied your patch.
