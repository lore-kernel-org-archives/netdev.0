From: Janice Girouard <girouard@us.ibm.com>
Subject: Re: patch for common networking error messages
Date: Mon, 16 Jun 2003 17:50:08 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFC2446DB8.6D4DA3ED-ON85256D47.007C79EE@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Daniel Stekloff <stekloff@us.ibm.com>, janiceg@us.ibm.com,
   jgarzik@pobox.com, kenistonj@us.ibm.com,
   Larry Kessler <lkessler@us.ibm.com>, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com, niv@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: David S. Miller <davem@redhat.com>
   Date:06/16/2003 05:27 PM

   And all the scripts checking for the existing messages in log files?
   Screw them, right?

That's a good point.  One possible suggestion would be to submit more than
one stdmsgs.h files.  One a legacy file, and one that is more consistent
from message to message.. shooting for a gradual migration.

Ultimately, I think standard messages would greatly support/simplify
scripts, especially between the myriad of ethernet drivers.  Each one
reports the data slightly differently, so you're error log analysis needs
to recognize 100 or so ways of being told that the link just went down.

Janice






                                                                                                                         
                      "David S. Miller"                                                                                  
                      <davem@redhat.com        To:       Janice Girouard/Austin/IBM@IBMUS                                
                      >                        cc:       Daniel Stekloff/Beaverton/IBM@IBMUS,                            
                                                janiceg@us.ltcfwd.linux.ibm.com, jgarzik@pobox.com,                      
                      06/16/2003 05:27          kenistonj@us.ibm.com, Larry Kessler/Beaverton/IBM@IBMUS,                 
                      PM                        linux-kernel@vger.kernel.org, netdev@oss.sgi.com,                        
                                                niv@us.ltcfwd.linux.ibm.com                                              
                                               Subject:  Re: patch for common networking error messages                  
                                                                                                                         
                                                                                                                         




   From: Janice Girouard <girouard@us.ibm.com>
   Date: Mon, 16 Jun 2003 17:29:15 -0500

   For the sake of consistency and automatic error log analysis, it might
be

And all the scripts checking for the existing messages
in log files?  Screw them, right?

This whole idea is starting to leave a very bad taste in
my mouth...
