From: Joe Perches <joe@perches.com>
Subject: Treewide frequency of various checkpatch messages
Date: Mon, 10 Mar 2014 09:02:26 -0700
Message-ID: <1394467346.24244.14.camel@joe-AO722>
References: <1394104358-23438-1-git-send-email-kys@microsoft.com>
 <1394104390-23477-1-git-send-email-kys@microsoft.com>
 <20140306.142919.763823800315842610.davem@davemloft.net>
 <1394148520.16156.8.camel@joe-AO722> <20140307075247.GA29018@mwanda>
 <1394184637.16156.58.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, apw@canonical.com,
 devel@linuxdriverproject.org, Andrew Morton <akpm@linux-foundation.org>,
 David Miller <davem@davemloft.net>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1394184637.16156.58.camel@joe-AO722>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-03-07 at 01:30 -0800, Joe Perches wrote:
> On Fri, 2014-03-07 at 10:54 +0300, Dan Carpenter wrote:
 (a question about a new message warning of a missing
  blank line between variable declaration blocks and
  code in a function)
> > How many warnings does this generate does this generate when you run it
> > across the whole tree?
> A lot.

Turns out it's 20,210 and it's the 14th
most common checkpatch message type.

    14    20210  WARNING:SPACING: Missing a blank line after declarations

> Check back with me after the week or so
> it'll take to run on this little netboook.

I ran a variant of this over the weekend
over next-20140306.  It just finished.

$ git ls-files | grep "\.[ch]$"| \
  while read file ; do \
    ./scripts/checkpatch.pl -f --strict --show-types --no-summary --emacs --terse $file ; \
  done | \
  tee -a checkpatch.all

Here are the top 100 types of messages:

(for    2377922 total LOC)

     1   241524  WARNING:LONG_LINE: line over 80 characters
     2   238492  ERROR:SPACING: space required after that ',' (ctx:VxV)
     3   152039  WARNING:LEADING_SPACE: please, no spaces at the start of a line
     4   117364  CHECK:CAMELCASE: Avoid CamelCase
     5    67761  CHECK:PARENTHESIS_ALIGNMENT: Alignment should match open parenthesis
     6    53673  ERROR:CODE_INDENT: code indent should use tabs where possible
     7    30981  ERROR:TRAILING_WHITESPACE: trailing whitespace
     8    30443  ERROR:C99_COMMENTS: do not use C99 // comments
     9    26928  WARNING:SPACE_BEFORE_TAB: please, no space before tabs
    10    25546  CHECK:AVOID_EXTERNS: extern prototypes should be avoided in .h files
    11    25384  WARNING:SPACING: space prohibited between function name and open parenthesis '('
    12    25209  WARNING:SPLIT_STRING: quoted string split across lines
    13    21410  WARNING:NETWORKING_BLOCK_COMMENT_STYLE: networking block comments don't use an empty /* line, use /* Comment...
    14    20210  WARNING:SPACING: Missing a blank line after declarations
    15    19881  CHECK:SPACING: No space is necessary after a cast
    16    18045  ERROR:SPACING: space prohibited after that open parenthesis '('
    17    17009  ERROR:COMPLEX_MACRO: Macros with complex values should be enclosed in parenthesis
    18    16674  ERROR:SPACING: space prohibited before that close parenthesis ')'
    19    14364  ERROR:SPACING: space required before the open parenthesis '('
    20    13331  ERROR:TRAILING_STATEMENTS: trailing statements should be on next line
    21    12619  CHECK:BRACES: braces {} should be used on all arms of this statement
    22    12605  CHECK:FSF_MAILING_ADDRESS: Do not include the paragraph about writing to the Free Software Foundation's mailing address from the sample GPL notice. The
    23    11194  ERROR:SPACING: spaces prohibited around that ':' (ctx:WxW)
    24    10192  ERROR:OPEN_BRACE: that open brace { should be on the previous line
    25     9941  WARNING:PREFER_PR_LEVEL: Prefer [subsystem eg: netdev]_err([subsystem]dev, ... then dev_err(dev, ... then pr_err(...  to printk(KERN_ERR ...
    26     9355  CHECK:BRACES: Blank lines aren't necessary after an open brace '{'
    27     9215  WARNING:NEW_TYPEDEFS: do not add new typedefs
    28     8733  ERROR:POINTER_LOCATION: "foo * bar" should be "foo *bar"
    29     8129  WARNING:PRINTK_WITHOUT_KERN_LEVEL: printk() should include KERN_ facility level
    30     7676  WARNING:BRACES: braces {} are not necessary for single statement blocks
    31     7339  CHECK:LOGICAL_CONTINUATIONS: Logical continuations should be on the previous line
    32     7247  ERROR:ASSIGN_IN_IF: do not use assignment in if condition
    33     6918  WARNING:NETWORKING_BLOCK_COMMENT_STYLE: networking block comments put the trailing */ on a separate line
    34     6750  ERROR:SPACING: spaces required around that '=' (ctx:VxV)
    35     6446  WARNING:SPACING: space prohibited before semicolon
    36     6289  WARNING:PREFER_PR_LEVEL: Prefer [subsystem eg: netdev]_info([subsystem]dev, ... then dev_info(dev, ... then pr_info(...  to printk(KERN_INFO ...
    37     6276  CHECK:MULTIPLE_ASSIGNMENTS: multiple assignments should be avoided
    38     6204  WARNING:VOLATILE: Use of volatile is usually wrong: see Documentation/volatile-considered-harmful.txt
    39     5921  CHECK:BRACES: Blank lines aren't necessary before a close brace '}'
    40     5262  WARNING:QUOTED_WHITESPACE_BEFORE_NEWLINE: unnecessary whitespace before a quoted newline
    41     5050  WARNING:NETWORKING_BLOCK_COMMENT_STYLE: networking block comments start with * on subsequent lines
    42     4740  WARNING:PREFER_PR_LEVEL: Prefer [subsystem eg: netdev]_warn([subsystem]dev, ... then dev_warn(dev, ... then pr_warn(...  to printk(KERN_WARNING ...
    43     4409  WARNING:PREFER_PR_LEVEL: Prefer [subsystem eg: netdev]_dbg([subsystem]dev, ... then dev_dbg(dev, ... then pr_debug(...  to printk(KERN_DEBUG ...
    44     4248  ERROR:SPACING: space required after that close brace '}'
    45     4237  ERROR:POINTER_LOCATION: "foo* bar" should be "foo *bar"
    46     4224  WARNING:EXPORT_SYMBOL: EXPORT_SYMBOL(foo); should immediately follow its function/variable
    47     4164  ERROR:RETURN_PARENTHESES: return is not a function, parentheses are not required
    48     3734  CHECK:ALLOC_SIZEOF_STRUCT: Prefer
    49     3651  CHECK:USLEEP_RANGE: usleep_range is preferred over udelay; see Documentation/timers/timers-howto.txt
    50     3597  WARNING:AVOID_EXTERNS: externs should be avoided in .c files
    51     3515  WARNING:SPACING: Unnecessary space before function pointer arguments
    52     3241  ERROR:ELSE_AFTER_BRACE: else should follow close brace '}'
    53     2995  WARNING:MEMORY_BARRIER: memory barrier without comment
    54     2713  ERROR:SPACING: space prohibited before that close square bracket ']'
    55     2337  ERROR:POINTER_LOCATION: "(foo*)" should be "(foo *)"
    56     2329  CHECK:UNCOMMENTED_DEFINITION: spinlock_t definition without comment
    57     2298  WARNING:PREFER_PACKED: __packed is preferred over __attribute__((packed))
    58     2180  ERROR:OPEN_BRACE: open brace '{' following struct go on the same line
    59     2032  CHECK:REDUNDANT_CODE: if this code is redundant consider removing it
    60     2017  ERROR:SPACING: space prohibited after that open square bracket '['
    61     1945  WARNING:BRACES: braces {} are not necessary for any arm of this statement
    62     1898  WARNING:MSLEEP: msleep < 20ms can sleep for up to 20ms; see Documentation/timers/timers-howto.txt
    63     1884  WARNING:MISSING_BREAK: Possible switch case/default not preceeded by break or fallthrough comment
    64     1869  WARNING:CONSTANT_CONVERSION: __constant_cpu_to_le32 should be cpu_to_le32
    65     1855  WARNING:PREFER_ETHER_ADDR_COPY: Prefer ether_addr_copy() over memcpy() if the Ethernet addresses are __aligned(2)
    66     1800  WARNING:SUSPECT_CODE_INDENT: suspect code indent for conditional statements (8, 12)
    67     1779  ERROR:SPACING: space required after that ',' (ctx:VxO)
    68     1773  ERROR:BRACKET_SPACE: space prohibited before open square bracket '['
    69     1664  WARNING:INDENTED_LABEL: labels should not be indented
    70     1620  ERROR:SPACING: need consistent spacing around '%' (ctx:WxV)
    71     1594  CHECK:SPACING: spaces required around that ':' (ctx:VxV)
    72     1519  ERROR:SPACING: space required before the open brace '{'
    73     1414  WARNING:STATIC_CONST_CHAR_ARRAY: static const char * array should probably be static const char * const
    74     1392  ERROR:SPACING: space required after that ';' (ctx:VxV)
    75     1376  WARNING:PREFER_SEQ_PUTS: Prefer seq_puts to seq_printf
    76     1363  WARNING:DEEP_INDENTATION: Too many leading tabs - consider code refactoring
    77     1328  CHECK:UNCOMMENTED_DEFINITION: struct mutex definition without comment
    78     1316  ERROR:INITIALISED_STATIC: do not initialise statics to 0 or NULL
    79     1287  WARNING:LINE_CONTINUATIONS: Avoid unnecessary line continuations
    80     1239  ERROR:SPACING: spaces required around that '<' (ctx:VxV)
    81     1181  ERROR:SWITCH_CASE_INDENT_LEVEL: switch and case should be at the same indent
    82     1129  ERROR:MULTISTATEMENT_MACRO_USE_DO_WHILE: Macros with multiple statements should be enclosed in a do - while loop
    83     1036  WARNING:PREFER_PR_LEVEL: Prefer pr_warn(... to pr_warning(...
    84      942  ERROR:SPACING: spaces required around that '==' (ctx:VxV)
    85      941  WARNING:INCLUDE_LINUX: Use #include <linux/io.h> instead of <asm/io.h>
    86      906  WARNING:CONSIDER_KSTRTO: simple_strtoul is obsolete, use kstrtoul instead
    87      836  ERROR:SPACING: spaces prohibited around that ':' (ctx:WxV)
    88      805  WARNING:PREFER_PR_LEVEL: Prefer [subsystem eg: netdev]_notice([subsystem]dev, ... then dev_notice(dev, ... then pr_notice(...  to printk(KERN_NOTICE ..
    89      803  ERROR:SPACING: space prohibited after that '!' (ctx:BxW)
    90      787  ERROR:SPACING: space required before that '-' (ctx:OxV)
    91      776  ERROR:SPACING: spaces required around that ':' (ctx:VxW)
    92      765  WARNING:INCLUDE_LINUX: Use #include <linux/uaccess.h> instead of <asm/uaccess.h>
    93      759  CHECK:INVALID_UTF8: Invalid UTF-8, patch and commit message should be encoded in UTF-8
    94      754  ERROR:SPACING: space required before that '&' (ctx:OxV)
    95      723  WARNING:SINGLE_STATEMENT_DO_WHILE_MACRO: Single statement macros should not use a do {} while (0) loop
    96      710  CHECK:ARCH_INCLUDE_LINUX: Consider using #include <linux/io.h> instead of <asm/io.h>
    97      707  ERROR:SPACING: spaces required around that '=' (ctx:VxW)
    98      691  WARNING:CVS_KEYWORD: CVS style keyword markers, these will _not_ be updated
    99      644  WARNING:SUSPECT_CODE_INDENT: suspect code indent for conditional statements (2, 4)
   100      641  ERROR:OPEN_BRACE: open brace '{' following function declarations go on the next line
