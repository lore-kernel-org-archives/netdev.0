From: =?ISO-8859-1?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
Subject: Re: tunnel xmit and h.raw
Date: Fri, 03 Oct 2003 18:49:27 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F7D9A87.3010005@kolumbus.fi>
References: <Pine.LNX.4.44.0310031750390.2761-100000@l>
Mime-Version: 1.0
Content-Type: multipart/alternative;
 boundary="------------030205090500090605040302"
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0310031750390.2761-100000@l>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030205090500090605040302
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii; format=flowed

If skb is shared skb_realloc_headroom() makes a private head, so no 
problem here. Actually the skb_cloned() test seems redundant in this 
context.

--Mika


Julian Anastasov wrote:

>	Hello,
>
>On Fri, 3 Oct 2003, David S. Miller wrote:
>
>  
>
>>>	Is the following change needed? May be yes for all kernels
>>>where the nearest skb_shared checks are actual.
>>>      
>>>
>>There seems to be no end to these kinds of bugs in the tunnel
>>drivers!
>>
>>Didn't we fix a nearly identical set of bugs in the tunnel
>>drivers just a month or two ago?
>>    
>>
>
>	The same place, but this one is special: h.raw is updated
>for us on reallocation but if the skb is shared I do not know if this is
>fatal for the other skb users, we change also their h.raw. But I rely
>on your opinion, may be it is safer with this change.
>
>  
>
>>I'll review this some more tomorrow and unless I find some problem
>>I'll apply your patch.  Thanks a lot.
>>    
>>
>
>Regards
>
>--
>Julian Anastasov <ja@ssi.bg>
>
>
>
>  
>

--------------030205090500090605040302
Content-Transfer-Encoding: 7bit
Content-Type: text/html; charset=us-ascii

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html;charset=ISO-8859-1">
  <title></title>
</head>
<body text="#000000" bgcolor="#ffffff">
If skb is shared skb_realloc_headroom() makes a private head, so no
problem here. Actually the skb_cloned() test seems redundant in this
context.<br>
<br>
--Mika<br>
<br>
<br>
Julian Anastasov wrote:<br>
<blockquote type="cite"
 cite="midPine.LNX.4.44.0310031750390.2761-100000@l">
  <pre wrap="">	Hello,

On Fri, 3 Oct 2003, David S. Miller wrote:

  </pre>
  <blockquote type="cite">
    <blockquote type="cite">
      <pre wrap="">	Is the following change needed? May be yes for all kernels
where the nearest skb_shared checks are actual.
      </pre>
    </blockquote>
    <pre wrap="">There seems to be no end to these kinds of bugs in the tunnel
drivers!

Didn't we fix a nearly identical set of bugs in the tunnel
drivers just a month or two ago?
    </pre>
  </blockquote>
  <pre wrap=""><!---->
	The same place, but this one is special: h.raw is updated
for us on reallocation but if the skb is shared I do not know if this is
fatal for the other skb users, we change also their h.raw. But I rely
on your opinion, may be it is safer with this change.

  </pre>
  <blockquote type="cite">
    <pre wrap="">I'll review this some more tomorrow and unless I find some problem
I'll apply your patch.  Thanks a lot.
    </pre>
  </blockquote>
  <pre wrap=""><!---->
Regards

--
Julian Anastasov <a class="moz-txt-link-rfc2396E" href="mailto:ja@ssi.bg">&lt;ja@ssi.bg&gt;</a>



  </pre>
</blockquote>
</body>
</html>

--------------030205090500090605040302--
