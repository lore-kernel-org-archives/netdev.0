From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Please ignore the corrupt patches sent earlier.
Date: Fri, 05 Nov 2004 15:47:40 -0500
Message-ID: <418BE6EC.3060103@pobox.com>
References: <200411050523.49239.raghavendra.koushik@s2io.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@oss.sgi.com, leonid.grossman@s2io.com,
        ravinandan.arakali@s2io.com, rapuru.sriram@s2io.com,
        alicia.pena@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: koushik <raghavendra.koushik@s2io.com>
In-Reply-To: <200411050523.49239.raghavendra.koushik@s2io.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

koushik wrote:
> Hi All,
> 	I had sent five of my patches with the new mail client, but it seems to have introduced 
> some series of '-' charecters at the end. So please ignore all those 5 mails, I will be sending
> the series of 12 patches again (hopefully for the last time :-)).


FWIW, I have found that use of "cat email-01.txt | sendmail -t" on a 
Unix system is the easiest way to send a large number of patches.

You simply have to provide a minimal email header, a blank line, and 
then the patch content itself, in a single text file.

Example:

$ cat > email-01.txt
To: jgarzik@pobox.com
CC: netdev@oss.sgi.com
From: koushik <raghavendra.koushik@s2io.com>
Subject: [patch 2.6.10-rc1-bk14 1/12] s2io: do something

EOF

$ cat patch-description >> email-01.txt
$ cat patch >> email-01.txt
$ sendmail -t < email-01.txt
