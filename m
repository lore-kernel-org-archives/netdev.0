From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: how to set the configuration EEPROM  back to the default setting
Date: Mon, 3 Feb 2003 13:24:19 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0302031319240.27729-100000@kenzo.iwr.uni-heidelberg.de>
References: <20030203082920.38177.qmail@web13306.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: =?iso-8859-1?q?nadia=20houziri?= <hona0005@yahoo.fr>
In-Reply-To: <20030203082920.38177.qmail@web13306.mail.yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 3 Feb 2003, [iso-8859-1] nadia houziri wrote:

>   1)how can i please Set the configuration EEPROM back 

By using the DOS-based tool that you used to set it to coaxial :-)

> 2)but how can i to explicitly set the media 

The Scyld page that you mentioned exoplains this. IN /etc/modules.conf, 
you need something like:

options 3c59x 3

to select BNC.

> 3)how to change the EEPROM to switch?

If you mean by this to just change the EEPROM every time you boot to 
switch to a different media type, then you shouldn't do it !
The EEPROM has a limited amount of writes and at some point you will not 
be able to write to it anymore.

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De
