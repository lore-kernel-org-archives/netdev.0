From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: ARGH MORE BUGS!!!
Date: Mon, 21 Feb 2005 21:56:06 +0100
Message-ID: <20050221205606.GB26248@electric-eye.fr.zoreil.com>
References: <421A3EB8.4050607@rapidforum.com> <20050221202854.GA26248@electric-eye.fr.zoreil.com> <421A45CA.80001@rapidforum.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Christian Schmid <webmaster@rapidforum.com>
Content-Disposition: inline
In-Reply-To: <421A45CA.80001@rapidforum.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christian Schmid <webmaster@rapidforum.com> :
[...]

Let's calm down, please.

# cat>/tmp/momo<<EOD
i=0
while : ; do
        cat /proc/slabinfo > /tmp/\$i
        i=$[ $i + 1 ]
        sleep 1
done
EOD
# nice -n -19 vmstat 1 > /tmp/v & nice -n -19 sh /tmp/momo

Wait a few minutes or more until the 5s pauses happen several times
and post the result somewhere.

I doubt I'll fix it but it should give nifty graphics.

--
Ueimor
