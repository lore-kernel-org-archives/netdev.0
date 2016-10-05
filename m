From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] Fixing a bug in team driver due to incorrect
 'unsigned  int' to 'int' conversion
Date: Thu, 06 Oct 2016 04:37:38 +0900
Message-ID: <1475696258.28155.219.camel@edumazet-glaptop3.roam.corp.google.com>
References: <3444639.ILgt5kU9OR@zbook>
         <1475636928.28155.196.camel@edumazet-glaptop3.roam.corp.google.com>
         <2440068.EFRMUI8i5V@zbook>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alex Sidorenko <alexandre.sidorenko@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33460 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932896AbcJEThu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2016 15:37:50 -0400
Received: by mail-pf0-f195.google.com with SMTP id i85so5495485pfa.0
        for <netdev@vger.kernel.org>; Wed, 05 Oct 2016 12:37:50 -0700 (PDT)
In-Reply-To: <2440068.EFRMUI8i5V@zbook>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-10-05 at 09:06 -0400, Alex Sidorenko wrote:
> Roundrobin runner of team driver uses 'unsigned int' variable to count the number of sent_packets.
> Later it is passed to a subroutine team_num_to_port_index(struct team *team, int num) as
> 'num' and when we reach MAXINT (2**31-1), 'num' becomes negative.
> 
> This leads to using incorrect hash-bucket for port lookup and as a result, packets are dropped. The fix
> consists of changing 'int num' to 'unsigned int num'. Testing of a fixed kernel shows that there
> is no packet drop anymore.
> 
> 
> Signed-off-by: Alex Sidorenko <alexandre.sidorenko@hpe.com>

Note that lines in your changelog are longer than the norm 
( Documentation/SubmittingPatches around line 619 )

 - The body of the explanation, line wrapped at 75 columns, which will
   be copied to the permanent changelog to describe this patch.

Otherwise, patch looks, welcome to the club Alex !

Acked-by: Eric Dumazet <edumazet@google.com>
