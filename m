From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: setting flow spec rules under vswitch configuration
Date: Wed, 10 Oct 2012 16:31:21 +0200
Message-ID: <507586B9.6080505@mellanox.com>
References: <5073F073.3060403@mellanox.com>  <1349801311.2800.17.camel@bwh-desktop.uk.solarflarecom.com>  <50758353.6050309@mellanox.com> <1349879306.6336.40.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rony Efraim <ronye@mellanox.com>, netdev <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:43413 "HELO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932252Ab2JJOeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 10:34:07 -0400
In-Reply-To: <1349879306.6336.40.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/10/2012 16:28, Ben Hutchings wrote:
> On Wed, 2012-10-10 at 16:16 +0200, Or Gerlitz wrote:
> [...]
>> >Thanks for setting the sketch of a plan here... so if we go little bit
>> >into details, we can safely move 20 bytes from the hadata[60] field into
>> >the beginning of struct ethtool_flow_ext, which will still allow old
>> >user space to work with newer kernels. As for newer uses space that
>> >would like to set mac addresses within
>> >ethtool_flow_ext, how are they supposed to identify if the kernel
>> >supports this extension (of the extension...)?
> Well they can't tell in advance, but we can define another flag in
> flow_type like FLOW_EXT and existing drivers will reject flow specs with
> that flag set.
I understand what we can add a flag which will be rejected by driver's 
that don't support this ext,
can the same/similar flag be used for newer user space code to mark they 
want this ext?

Or.
