From: Felix Radensky <felix@allot.com>
Subject: Re: e100 "Ferguson" release
Date: Tue, 05 Aug 2003 18:44:10 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F2FD0CA.1080403@allot.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E01022292A4@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
 boundary="Boundary_(ID_Lg9l6CsjxHY6kAV0DHDKJw)"
Cc: Ben Greear <greearb@candelatech.com>, Jeff Garzik <jgarzik@pobox.com>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary_(ID_Lg9l6CsjxHY6kAV0DHDKJw)
Content-type: text/plain; charset=us-ascii; format=flowed
Content-transfer-encoding: 7BIT

Hi, Scott

This change seems to fix the problem.
Thanks a lot !

Felix.

Feldman, Scott wrote:

>>I've also noticed that the number of hard_start_xmit failures 
>>in e1000 has increased significantly in version 5.1.13-k1. In 
>>version 5.0.43-k1 the number of failures was much smaller.
>>    
>>
>
>Interesting.  Felix, would you undo the change[1] below in 5.1.13-k1 and
>see what happens?  With the change below, 5.1.13 would be more
>aggressive on Tx cleanup, so we'll be quicker waking the queue than
>before. 
>
>-scott
>
>        for(i = 0; i < E1000_MAX_INTR; i++)
>-               if(!e1000_clean_rx_irq(adapter) &&
>+               if(!e1000_clean_rx_irq(adapter) &
>                   !e1000_clean_tx_irq(adapter))
>                        break;
>
>[1] Something still bothers me about this new form where we're mixing a
>bit-wise operator with logical operands.  Should this bother me?
>
>  
>


--Boundary_(ID_Lg9l6CsjxHY6kAV0DHDKJw)
Content-type: text/html; charset=us-ascii
Content-transfer-encoding: 7BIT

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <title></title>
</head>
<body>
Hi, Scott<br>
<br>
This change seems to fix the problem. <br>
Thanks a lot ! <br>
<br>
Felix.<br>
<br>
Feldman, Scott wrote:<br>
<blockquote type="cite"
 cite="midC6F5CF431189FA4CBAEC9E7DD5441E01022292A4@orsmsx402.jf.intel.com">
  <blockquote type="cite">
    <pre wrap="">I've also noticed that the number of hard_start_xmit failures 
in e1000 has increased significantly in version 5.1.13-k1. In 
version 5.0.43-k1 the number of failures was much smaller.
    </pre>
  </blockquote>
  <pre wrap=""><!---->
Interesting.  Felix, would you undo the change[1] below in 5.1.13-k1 and
see what happens?  With the change below, 5.1.13 would be more
aggressive on Tx cleanup, so we'll be quicker waking the queue than
before. 

-scott

        for(i = 0; i &lt; E1000_MAX_INTR; i++)
-               if(!e1000_clean_rx_irq(adapter) &amp;&amp;
+               if(!e1000_clean_rx_irq(adapter) &amp;
                   !e1000_clean_tx_irq(adapter))
                        break;

[1] Something still bothers me about this new form where we're mixing a
bit-wise operator with logical operands.  Should this bother me?

  </pre>
</blockquote>
<br>
</body>
</html>

--Boundary_(ID_Lg9l6CsjxHY6kAV0DHDKJw)--
