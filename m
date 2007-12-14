From: "senthil kumar" <psenthilkumar.accet@gmail.com>
Subject: SCTP Notification
Date: Fri, 14 Dec 2007 10:07:19 +0900
Message-ID: <9b936a040712131707p4aba0d51w6c5f3fdd9f6e9543@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0622162890=="
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org
To: bidulock@openss7.org, sigtran@ietf.org
Return-path: <sigtran-bounces@ietf.org>
List-Unsubscribe: <https://www1.ietf.org/mailman/listinfo/sigtran>,
	<mailto:sigtran-request@ietf.org?subject=unsubscribe>
List-Post: <mailto:sigtran@ietf.org>
List-Help: <mailto:sigtran-request@ietf.org?subject=help>
List-Subscribe: <https://www1.ietf.org/mailman/listinfo/sigtran>,
	<mailto:sigtran-request@ietf.org?subject=subscribe>
Errors-To: sigtran-bounces@ietf.org
List-Id: netdev.vger.kernel.org

--===============0622162890==
Content-Type: multipart/alternative;
	boundary="----=_Part_32877_8146781.1197594439229"

------=_Part_32877_8146781.1197594439229
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

    I am using SCTP(libsctp) in linux 2.6.9. I have subscribed for
Notifications. However, i am not getting any notification when sctp
association is established or peer is shutdown. Is there any correction in
my method of subscription? setsockopt system call is returning success. i
used getsockopt to verify the same.

      struct sockaddr_in stSrcIPAddress;
      socklen_t  Addlen=sizeof(sockaddr_in);
      int  iFlags=-1,iRet=-1;

      struct sctp_sndrcvinfo sndrcvinfo;
      struct sctp_event_subscribe events;

  memset( (void *)&events, 0, sizeof(events) );
  events.sctp_data_io_event = 1;
  events.sctp_association_event = 1;
  events.sctp_send_failure_event = 1;
  events.sctp_shutdown_event = 1;
  events.sctp_peer_error_event = 1;

  ret = setsockopt( iconnSock, IPPROTO_SCTP, SCTP_EVENTS,(const void
*)&events, sizeof(events) );
  while(1)
  {
    iRet = sctp_recvmsg(iconnSock, (void *)pacbuffer,600, (struct sockaddr
*)&stSrcIPAddress, &Addlen, &sndrcvinfo, &iFlags );
    if ( iRet < 0)
    {
    }
    if(iFlags & MSG_NOTIFICATION )//Notification/event is received.
    {
    }
    if (iRet> 0)
    {
    }
}

with regards,
   senthil

------=_Part_32877_8146781.1197594439229
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,<br><br>&nbsp;&nbsp;&nbsp; I am using SCTP(libsctp) in linux 2.6.9. I have subscribed for Notifications. However, i am not getting any notification when sctp association is established or peer is shutdown. Is there any correction in my method of subscription? setsockopt system call is returning success. i used getsockopt to verify the same.
<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; struct sockaddr_in stSrcIPAddress;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; socklen_t&nbsp; Addlen=sizeof(sockaddr_in);<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; int&nbsp; iFlags=-1,iRet=-1;<br>&nbsp;&nbsp;&nbsp;&nbsp; <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; struct sctp_sndrcvinfo sndrcvinfo;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; struct sctp_event_subscribe events;
<br><br>&nbsp; memset( (void *)&amp;events, 0, sizeof(events) );<br>&nbsp; events.sctp_data_io_event = 1;<br>&nbsp; events.sctp_association_event = 1;<br>&nbsp; events.sctp_send_failure_event = 1;<br>&nbsp; events.sctp_shutdown_event = 1;<br>&nbsp; events.sctp_peer_error_event
 = 1;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <br>&nbsp; ret = setsockopt( iconnSock, IPPROTO_SCTP, SCTP_EVENTS,(const void *)&amp;events, sizeof(events) );<br>&nbsp; while(1)<br>&nbsp; {<br>&nbsp;&nbsp;&nbsp; iRet = sctp_recvmsg(iconnSock, (void *)pacbuffer,600, (struct sockaddr *)&amp;stSrcIPAddress, &amp;Addlen, &amp;sndrcvinfo, &amp;iFlags );
<br>&nbsp;&nbsp;&nbsp; if ( iRet &lt; 0)<br>&nbsp;&nbsp;&nbsp; {<br>&nbsp;&nbsp;&nbsp; }<br>&nbsp;&nbsp;&nbsp; if(iFlags &amp; MSG_NOTIFICATION )//Notification/event is received.<br>&nbsp;&nbsp;&nbsp; {<br>&nbsp;&nbsp;&nbsp; }<br>&nbsp;&nbsp;&nbsp; if (iRet&gt; 0)<br>&nbsp;&nbsp;&nbsp; {<br>&nbsp;&nbsp;&nbsp; }<br>}<br><br>with regards,<br>&nbsp;&nbsp; senthil<br>
<br>

------=_Part_32877_8146781.1197594439229--




--===============0622162890==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Sigtran mailing list
Sigtran@ietf.org
https://www1.ietf.org/mailman/listinfo/sigtran

--===============0622162890==--
