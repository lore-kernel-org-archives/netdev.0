From: "Paul Albrecht" <palbrecht@qwest.net>
Subject: Re: question about linux tcp request queue handling
Date: Sun, 6 Jul 2003 17:12:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <001a01c3441c$6fe111a0$6801a8c0@oemcomputer>
References: <3F08858E.8000907@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, "netdev" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Nivedita Singhvi" <niv@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Nivedita writes:

>
> Do you have tcp_syncookies on?
>

syncookies = 0.

>
>And are you exceeding the len as configured by tcp_max_syn_backlog?
>

max_syn_backlog = 256.

My server program sets its backlog to one and pauses ninety seconds before
accepting connections.  Within that ninety second interval, I start three
client programs that do an active open to my server.  I expect one of
connections to get discarded when the server's connection backlog limit is
exceeded.
