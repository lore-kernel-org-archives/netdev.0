From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: how to report network device errors to userspace?
Date: Wed, 19 Jun 2002 14:39:53 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <3D10CFF9.B4072FEA@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org


I'm curious about the proper way for a network device driver to report faults to
userspace.

The network devices don't seem to have /dev entries as a rule, so that makes it
difficult to use select/poll to alert a user app.

I haven't been able to find a standard interface for this--does nobody care
about this kind of thing?

-- 
Chris Friesen                    | MailStop: 043/33/F10  
Nortel Networks                  | work: (613) 765-0557
3500 Carling Avenue              | fax:  (613) 765-2986
Nepean, ON K2H 8E9 Canada        | email: cfriesen@nortelnetworks.com
