From: Matthias Welk <welk@fokus.gmd.de>
Subject: Re: PROBLEM: udp not delivered on special socket receive buffer size
Date: Wed, 10 Jul 2002 12:44:15 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <200207101244.15458.welk@fokus.gmd.de>
References: <200207100856.MAA25289@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com, davem@redhat.com, pekkas@netcore.fi,
   gober@fokus.gmd.de
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200207100856.MAA25289@sex.inr.ac.ru>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

On Wednesday 10 July 2002 10:56, kuznet@ms2.inr.ac.ru wrote:

>> The probles is, that I did not receive any udp packets (224 bytes), if the=
>> =20
>> receive buffer size (SO_RCVBUF) of the socket is set to a value below 
831=20
>> (??) bytes.
>
>Apparently, 831 is not enough to allow to queue such buffer.
>
>Tune value of "rx_copybreak" for ethernet to value sort of 1000.
>It is module parameter for most of drivers.
>

But shouldn't it not be working without tuning via kernel module parameters ?
And where is the relation between the "rx_copybreak" -value and the socket, I 
mean why is it working if I increase receive buffer size ?
And shouldn't the minimum size set to a minum working value ?

Thanks, Matthias.
-- 
---------------------------------------------------------------
From: Matthias Welk                   office:  +49-30-3463-7272
      FHG Fokus                       mobile:  +49-179- 1144752
      Kaiserin-Augusta-Allee 31       fax   :  +49-30-3463-8672
      10589 Berlin		      email : welk@fokus.fhg.de
----------------------------------------------------------------
