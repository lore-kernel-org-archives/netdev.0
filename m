From: Matthias Welk <welk@fokus.gmd.de>
Subject: PROBLEM: udp not delivered on special socket receive buffer size
Date: Wed, 10 Jul 2002 09:45:11 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <200207100945.13002.welk@fokus.gmd.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
   Peter Gober <gober@fokus.gmd.de>
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

Hi,

I reported the following problem allready to the linux-kernel mailinglist, but 
did not receive any answer. I hope you are the right contacts for this.

The probles is, that I did not receive any udp packets (224 bytes), if the 
receive buffer size (SO_RCVBUF) of the socket is set to a value below 831 
(??) bytes.
Yes, you may ask why such a low value, but I have no influence on this, 
because it is set in the Java Media Framework internally.
You can check this behaviour with a small c-program too.

So my question is:

Is this a bug or are there any reasons for this magic 831 bytes barrier ?

Thanks, Matthias.
-- 
---------------------------------------------------------------
From: Matthias Welk                   office:  +49-30-3463-7272
      FHG Fokus                       mobile:  +49-179- 1144752
      Kaiserin-Augusta-Allee 31       fax   :  +49-30-3463-8672
      10589 Berlin		      email : welk@fokus.fhg.de
----------------------------------------------------------------
