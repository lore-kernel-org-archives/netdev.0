From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] LSM networking: tcp hooks for 2.5.42 (7/7)
Date: Tue, 15 Oct 2002 10:41:46 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021015.104146.112719962.davem@redhat.com>
References: <Mutt.LNX.4.44.0210160030350.27676-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, linux-security-module@wirex.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jmorris@intercode.com.au
In-Reply-To: <Mutt.LNX.4.44.0210160030350.27676-100000@blackbird.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I totally reject all of these LSM networking patches.

The more I read of them the more I hate them.

You have to hide this stuff away so that:

1) I don't read it when I read the normal networking code
2) It doesn't get built into my tree because there is no way
   we're going to add all of these nop function calls all over
   the stack in the most critical of places
