From: Akshay Kawale <linux781@gmail.com>
Subject: Difference between skb_put() and skb_push()
Date: Thu, 31 Mar 2005 00:46:03 -0500
Message-ID: <72252ed05033021463a1f45b6@mail.gmail.com>
Reply-To: Akshay Kawale <linux781@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I was wondering about the difference between skb_put() and skb_push().
Both appear to take in the same parameters and produce the same result
- that of lengthening the data area.

If I wanted to add data before the current data area, which one should I use?
(e.g. my data is 5678... and I wanted to prepend 1234 to it).

I am using these functions in a Netfilter hook to insert a header
between TCP and IP for a course project I am doing.

Please help me!!! :-)

Thanks.

- Akshay
