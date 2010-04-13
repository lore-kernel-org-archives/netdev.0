From: stephen mulcahy <smulcahy@gmail.com>
Subject: Re: forcedeth driver hangs under heavy load
Date: Tue, 13 Apr 2010 16:25:20 +0100
Message-ID: <4BC48CE0.1080504@gmail.com>
References: <4B9E6C60.7030300@atlanticlinux.ie>	 <20100315182220.GQ2763@decadent.org.uk> <4B9F5E5E.2060209@atlanticlinux.ie>	 <1270393967.8341.11.camel@localhost> <4BBCA19C.5080204@atlanticlinux.ie>	 <1270942606.6179.64.camel@localhost> <4BC2EF88.3060203@atlanticlinux.ie>	 <4BC31486.1090603@gmail.com> <1271076426.16881.21.camel@edumazet-laptop>	 <4BC31AA0.5070006@gmail.com> <4BC31DDE.7010005@gmail.com>	 <1271085862.16881.38.camel@edumazet-laptop> <4BC3461D.3070002@gmail.com>	 <1271091581.16881.41.camel@edumazet-laptop> <4BC44167.4080807@gmail.com>	 <1271155766.16881.245.camel@edumazet-laptop> <4BC44EC8.1010104@gmail.com>	 <1271160298.2098.0.camel@achroite.uk.solarflarecom.com>	 <4BC47F38.5040509@gmail.com> <1271169741.16881.437.camel@edumazet-laptop>	 <4BC48460.4040001@gmail.com> <12711711
 07.16881.465.camel@edumazet-laptop>	 <4BC488DA.3020508@gmail.com> <1271172172.16881.484.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Ayaz Abdulla <aabdulla@nvidia.com>, 572201@bugs.debian.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([62.179.121.38]:53184 "EHLO
	viefep18-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753178Ab0DMPZ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 11:25:27 -0400
In-Reply-To: <1271172172.16881.484.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> OK, thanks for clarification.
> 
> Last question, did you tried a vanilla kernel, aka 2.6.33.2 for
> example ?

I built a Debian package from the vanilla 2.6.33.2 and installed that on 
all nodes and tried my reproducer with the same results - nodes becoming 
unresponsive.

I didn't try changing the tso and tx settings with the 2.6.33.2 kernel 
though. Let me know if that would be useful (and/or if there is another 
kernel that you would like me to test with) and I'll try to fit it in.

Thanks again for your help.

-stephen
