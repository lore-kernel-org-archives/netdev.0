From: Christoph Hellwig <hch@lst.de>
Subject: RNIC-PI Specification
Date: Tue, 19 Apr 2005 13:49:50 +0200
Message-ID: <20050419114950.GA16258@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: rnic-pi-comments@opengroup.org
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Some comments on the RNIC-PI Draft at 
http://www.opengroup.org/icsc/rnicpi/uploads/40/7235/rnicpi_draft1.pdf:

 (1) You're repeating the common mistake of mixing up a userland API
     with a kernel API specification.  The Linux community and many
     others in the free software world don't care about these kind of
     kernel API specifications.  Please split this into an optional
     sub-specification if you want to be take serious.
     (Note: In the following points I'm completely skipping the kernel
      part of the specification as it is irrelevant for Linux anyway)

 (2) In a lot of places you're talking about "IHV private" data or
     functionality.  This doesn't make any sense in the free software
     world.  Please change the wording to "driver private" or just
     get rid of it completely - in many cases it's just papering over
     a bad design of the sofware stack.
  
 (3) Please don't expose the difference between driver/os/whatever
     private data to the API user.  It's the operating systems's job
     to provide such abstraction.

 (4) Please get rid of all the ri_consumer_domain_t arguments in the
     userland API.  They're useless and the API is already compicated
     enough

 (5) Please get rid of the IN and OUT specifiers in the API.  C doesn't
     have any concept of in vs out pointer and it's obsufcating the API
     needlessly.

 (6) If ri_modify_rnic isn't supported in userland don't specify it.
     Please keep the APIs simple.

I've stopped reading throught the specification after the first 50
pages, I'll take another look once the above issues are fixed.
