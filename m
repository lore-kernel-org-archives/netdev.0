From: Pekka Savola <pekkas@netcore.fi>
Subject: IPv6 on-link assumption considered harmful
Date: Thu, 30 Oct 2003 21:09:03 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0310302106000.22649-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-ID: <Pine.LNX.4.44.0310302106002.22649@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

FYI,

IPv6 Neighbor Discovery installs default routes on every interface with a 
high metric, i.e., if no other way to know how to treat the packet, it's 
assumed to be "on-link".

This causes a number of problems, especially if you have enabled IPv6 but 
don't have IPv6 connectivity yet.

This "feature" will likely be removed from Neighbor Discovery in its 
revision.

Just to give a heads-up before this is finalized, to give people ability 
to prepare or comment prior to this process is formalized in the IETF.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
---------- Forwarded message ----------
Date: Thu, 23 Oct 2003 09:30:54 -0400
From: Internet-Drafts@ietf.org
To: IETF-Announce:  ;
Cc: v6ops@ops.ietf.org
Subject: I-D ACTION:draft-ietf-v6ops-onlinkassumption-00.txt

A New Internet-Draft is available from the on-line Internet-Drafts directories.
This draft is a work item of the IPv6 Operations Working Group of the IETF.

	Title		: IPv6 Neighbor Discovery On-Link Assumption 
			  Considered Harmful
	Author(s)	: S. Roy, et. al.
	Filename	: draft-ietf-v6ops-onlinkassumption-00.txt
	Pages		: 11
	Date		: 2003-10-22
	
This document proposes a change to the IPv6 Neighbor Discovery
conceptual host sending algorithm.  According to the algorithm, when
a host's default router list is empty, the host assumes that all
destinations are on-link.  This document describes how making this
assumption causes problems, and describes how these problems outweigh
the benefits of this part of the conceptual sending algorithm.

A URL for this Internet-Draft is:
http://www.ietf.org/internet-drafts/draft-ietf-v6ops-onlinkassumption-00.txt

To remove yourself from the IETF Announcement list, send a message to 
ietf-announce-request with the word unsubscribe in the body of the message.

Internet-Drafts are also available by anonymous FTP. Login with the username
"anonymous" and a password of your e-mail address. After logging in,
type "cd internet-drafts" and then
	"get draft-ietf-v6ops-onlinkassumption-00.txt".

A list of Internet-Drafts directories can be found in
http://www.ietf.org/shadow.html 
or ftp://ftp.ietf.org/ietf/1shadow-sites.txt


Internet-Drafts can also be obtained by e-mail.

Send a message to:
	mailserv@ietf.org.
In the body type:
	"FILE /internet-drafts/draft-ietf-v6ops-onlinkassumption-00.txt".
	
NOTE:	The mail server at ietf.org can return the document in
	MIME-encoded form by using the "mpack" utility.  To use this
	feature, insert the command "ENCODING mime" before the "FILE"
	command.  To decode the response(s), you will need "munpack" or
	a MIME-compliant mail reader.  Different MIME-compliant mail readers
	exhibit different behavior, especially when dealing with
	"multipart" MIME messages (i.e. documents which have been split
	up into multiple messages), so check your local documentation on
	how to manipulate these messages.
		
		
Below is the data which will enable a MIME compliant mail reader
implementation to automatically retrieve the ASCII version of the
Internet-Draft.
